port module App exposing (..)

import Html exposing (Html, text, div, img, input, span)
import Html.Attributes as H exposing (src, class, type_, classList)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error)
import Json.Decode exposing (Decoder, at, string, bool, float, nullable, list)
import Json.Decode.Pipeline exposing (decode, required)
import Http
import Json.Encode
import Material.Slider as Slider
import Material.Button as Button
import Material.Options as Options
import Material
import Material.Icon as Icon
import Time exposing (Time, second, inSeconds)
import Task exposing (Task)
import Date


---- MODEL ----


type alias Model =
    { message : String
    , selectedZone : Maybe String
    , showingModal : Modals
    , color : Color
    , mdl : Material.Model
    , zones : List Zone
    , currentTime : Time
    , claimTicketTime : Maybe Time
    , claimTicket : Maybe String
    , claimedFlameThrower : Bool
    }


type Modals
    = ColorPicker
    | Info
    | FlameThrower
    | None


type alias Color =
    { red : Float
    , blue : Float
    , green : Float
    }


type alias Coordinate =
    { longitude : Float
    , latitude : Float
    }


type alias Zone =
    { name : String
    , available : Bool
    , colour : Maybe String
    , coordinates : List Coordinate
    , claimTicket : Maybe String
    }


type alias Claim =
    { expirationTime : Time }


zonesDecoder : Decoder (List Zone)
zonesDecoder =
    list zoneDecoder


zoneDecoder : Decoder Zone
zoneDecoder =
    decode Zone
        |> required "name" string
        |> required "available" bool
        |> required "colour" (nullable string)
        |> required "coordinates" (list coordinateDecoder)
        |> required "claimTicket" (nullable string)


coordinateDecoder : Decoder Coordinate
coordinateDecoder =
    decode Coordinate
        |> required "latitude" float
        |> required "longitude" float


claimDecoder : Decoder Claim
claimDecoder =
    decode Claim
        |> required "expirationTime" dateDecoder


dateDecoder : Decoder Time
dateDecoder =
    string
        |> Json.Decode.andThen
            (\dateString ->
                case (Date.fromString dateString) of
                    Ok date ->
                        Json.Decode.succeed (Date.toTime date)

                    Err errorString ->
                        Json.Decode.fail errorString
            )


init : ( Model, Cmd Msg )
init =
    ( { message = ""
      , selectedZone = Nothing
      , showingModal = None
      , color =
            { red = 50
            , blue = 50
            , green = 50
            }
      , mdl = Material.model
      , zones = []
      , currentTime = 0
      , claimTicketTime = Nothing
      , claimTicket = Nothing
      , claimedFlameThrower = False
      }
    , getZones
    )


getZones : Cmd Msg
getZones =
    Http.send
        GetZones
        (Http.get ("http://kubernetes.strocamp.net:8888/zones/") zonesDecoder)



---- UPDATE ----


type Msg
    = OpenColorPicker String
    | ClaimTicketTime Time
    | Tick Time
    | OpenInfo
    | OpenFlameThrower
    | CloseDialog
    | ChooseColor
    | ClaimFlameThrower
    | FireFlameThrower Int
    | CallFlameThrowerFire (Result Error Claim)
    | CallFlameThrowerClaim (Result Error Claim)
    | CallApi (Result Error Zone)
    | GetZones (Result Error (List Zone))
    | UpdateRed Float
    | UpdateBlue Float
    | UpdateGreen Float
    | Mdl (Material.Msg Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            let
                expirationTime =
                    Maybe.withDefault 0 model.claimTicketTime

                claimExpired =
                    newTime > expirationTime
            in
                if claimExpired then
                    ( { model | currentTime = newTime, message = "", claimedFlameThrower = False, claimTicket = Nothing, claimTicketTime = Nothing }, Cmd.none )
                else
                    ( { model | currentTime = newTime }, Cmd.none )

        ClaimTicketTime time ->
            ( { model | claimTicketTime = Just (time + (second * 120)) }, Cmd.none )

        Mdl msg_ ->
            Material.update Mdl msg_ model

        OpenColorPicker string ->
            ( { model | selectedZone = Just string, showingModal = ColorPicker }, Cmd.none )

        OpenInfo ->
            ( { model | showingModal = Info }, Cmd.none )

        OpenFlameThrower ->
            ( { model | showingModal = FlameThrower }, Cmd.none )

        CloseDialog ->
            ( { model | showingModal = None, message = "" }, Cmd.none )

        ChooseColor ->
            ( model, chooseColor model.selectedZone model.color )

        ClaimFlameThrower ->
            ( model, claimFlameThrower model.claimTicket )

        FireFlameThrower action ->
            ( model, fireFlameThrower model.claimTicket action )

        CallFlameThrowerClaim (Ok claim) ->
            ( { model | claimedFlameThrower = True, claimTicketTime = Just claim.expirationTime }, Cmd.none )

        CallFlameThrowerClaim (Err _) ->
            ( { model | message = "Could not claim flamethrower" }, Cmd.none )

        CallFlameThrowerFire (Ok claim) ->
            ( { model | claimedFlameThrower = True, claimTicketTime = Just claim.expirationTime }, Cmd.none )

        CallFlameThrowerFire (Err _) ->
            ( { model | message = "Could not claim flamethrower" }, Cmd.none )

        CallApi (Ok zone) ->
            let
                newZones =
                    zoneMapper zone model.zones
            in
                ( { model | showingModal = None, message = "", zones = newZones }, setZones newZones )

        CallApi (Err _) ->
            ( { model | message = "Could not claim this light, already claimed" }, Cmd.none )

        GetZones (Err _) ->
            ( model, Cmd.none )

        GetZones (Ok zones) ->
            let
                claimTicket =
                    hasClaimTicket zones
            in
                case claimTicket of
                    Nothing ->
                        ( { model | zones = zones, claimTicket = Nothing, claimTicketTime = Nothing }, setZones zones )

                    Just ticket ->
                        ( { model | zones = zones, claimTicket = claimTicket }, Cmd.batch [ setZones zones, Task.perform ClaimTicketTime Time.now ] )

        UpdateRed val ->
            ( { model | color = (redUpdater val model.color) }, Cmd.none )

        UpdateBlue val ->
            ( { model | color = (blueUpdater val model.color) }, Cmd.none )

        UpdateGreen val ->
            ( { model | color = (greenUpdater val model.color) }, Cmd.none )


redUpdater : Float -> Color -> Color
redUpdater val color =
    { color | red = val }


blueUpdater : Float -> Color -> Color
blueUpdater val color =
    { color | blue = val }


greenUpdater : Float -> Color -> Color
greenUpdater val color =
    { color | green = val }


zoneMapper : Zone -> List Zone -> List Zone
zoneMapper zone list =
    let
        zoneUpdater =
            (\newZone zone ->
                if newZone.name == zone.name then
                    newZone
                else
                    zone
            )
    in
        List.map (zoneUpdater zone) list


hasClaimTicket : List Zone -> Maybe String
hasClaimTicket list =
    List.foldr
        (\listItem hasClaim ->
            case hasClaim of
                Just claim ->
                    hasClaim

                Nothing ->
                    if listItem.name == "FlameThrowers" then
                        listItem.claimTicket
                    else
                        Nothing
        )
        Nothing
        list


isFireActive : Model -> Bool
isFireActive model =
    case model.claimTicket of
        Just _ ->
            True

        Nothing ->
            False



---- VIEW ----


view : Model -> Html Msg
view model =
    case model.showingModal of
        ColorPicker ->
            modal model (modalColorPicker model)

        Info ->
            modal model modalInfo

        FlameThrower ->
            modal model (modalFire model)

        None ->
            div [] [ navbar (isFireActive model) ]


modal : Model -> Html Msg -> Html Msg
modal model content =
    let
        fireIsActive =
            isFireActive model
    in
        div []
            [ navbar fireIsActive
            , div [ class "modal" ]
                [ div [ class "header" ]
                    [ div [ onClick CloseDialog, class "close" ] [ Icon.i "close" ] ]
                , content
                ]
            ]


modalFire : Model -> Html Msg
modalFire model =
    if model.claimedFlameThrower then
        timeToPlayWithFlameThrower model
    else
        timeToClaimFlameThrower model


timeToClaimFlameThrower : Model -> Html Msg
timeToClaimFlameThrower model =
    case model.claimTicketTime of
        Just time ->
            div [] [ text "claim", timer (round ((time - model.currentTime) / 1000)), claimFlamethrowerButton model ]

        Nothing ->
            div [] [ text "no ticket" ]


timeToPlayWithFlameThrower : Model -> Html Msg
timeToPlayWithFlameThrower model =
    case model.claimTicketTime of
        Just time ->
            div []
                [ timer (round ((time - model.currentTime) / 1000))
                , playWithFlamethrowerButton model 1
                , playWithFlamethrowerButton model 2
                , playWithFlamethrowerButton model 3
                , playWithFlamethrowerButton model 4
                ]

        Nothing ->
            div [] [ text "no ticket" ]


timer : Int -> Html Msg
timer timeLeft =
    let
        seconds =
            rem timeLeft 60

        minutes =
            timeLeft // 60
    in
        div [ class "timer" ]
            [ span [ class "minutes" ] [ text (toString minutes) ]
            , span [ class "colon" ] [ text " : " ]
            , span [ class "seconds" ] [ text (toString seconds) ]
            ]


playWithFlamethrowerButton : Model -> Int -> Html Msg
playWithFlamethrowerButton model action =
    Button.render Mdl
        [ 0 ]
        model.mdl
        [ Button.raised
        , Button.ripple
        , Options.onClick (FireFlameThrower action)
        ]
        [ text ("Fire " ++ (toString action)) ]


claimFlamethrowerButton : Model -> Html Msg
claimFlamethrowerButton model =
    Button.render Mdl
        [ 0 ]
        model.mdl
        [ Button.raised
        , Button.ripple
        , Options.onClick ClaimFlameThrower
        ]
        [ text "Claim" ]


modalInfo : Html Msg
modalInfo =
    div [] [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. " ]


modalColorPicker : Model -> Html Msg
modalColorPicker model =
    div [ class "content" ]
        [ preview model.color
        , slider model.color.red UpdateRed "Red"
        , slider model.color.blue UpdateBlue "Blue"
        , slider model.color.green UpdateGreen "Green"
        , errorMessage model.message
        , callApiButton model
        ]


errorMessage : String -> Html msg
errorMessage errorMessage =
    if errorMessage == "" then
        div [] []
    else
        div [ class "error" ] [ text errorMessage ]


navbar : Bool -> Html Msg
navbar fireIsActive =
    div [ class "nav" ]
        [ div [ class "title" ] [ text "ColourMySha" ]
        , div [ classList [ ( "fire", True ), ( "active", fireIsActive ) ], onClick OpenFlameThrower ] [ Icon.i "warning" ]
        , div [ class "info", onClick OpenInfo ] [ Icon.i "info" ]
        ]


callApiButton : Model -> Html Msg
callApiButton model =
    Button.render Mdl
        [ 0 ]
        model.mdl
        [ Button.raised
        , Button.ripple
        , Options.onClick ChooseColor
        ]
        [ text "Set color" ]


decodeChooseColorResponse : Decoder String
decodeChooseColorResponse =
    at [ "data", "image_url" ] string


preview : Color -> Html msg
preview color =
    let
        red =
            toString <| round <| (color.red / 100 * 256)

        blue =
            toString <| round <| (color.blue / 100 * 256)

        green =
            toString <| round <| (color.green / 100 * 256)

        colorString =
            "rgb(" ++ red ++ ", " ++ green ++ ", " ++ blue ++ ")"

        style =
            H.style
                [ ( "background-color", colorString )
                ]
    in
        div
            [ class "color-preview", style ]
            []



--        div [ class "color-preview", style ] []


slider : Float -> (Float -> Msg) -> String -> Html Msg
slider float msg title =
    div []
        [ text title
        , Slider.view
            [ Slider.onChange msg
            , Slider.value float
            ]
        ]



-- ENCODERS


colorEncoder : Color -> Json.Encode.Value
colorEncoder color =
    let
        attributes =
            [ ( "red", Json.Encode.float (color.red / 100) )
            , ( "blue", Json.Encode.float (color.blue / 100) )
            , ( "green", Json.Encode.float (color.green / 100) )
            ]
    in
        Json.Encode.object attributes


chooseColor : Maybe String -> Color -> Cmd Msg
chooseColor selectedZone color =
    case selectedZone of
        Just selectedZone ->
            let
                url =
                    "http://kubernetes.strocamp.net:8888/zones/" ++ selectedZone ++ "/claim"

                request =
                    Http.request
                        { method = "PUT"
                        , url = url
                        , headers = []
                        , body = colorEncoder color |> Http.jsonBody
                        , timeout = Nothing
                        , expect = Http.expectJson zoneDecoder
                        , withCredentials = False
                        }
            in
                Http.send CallApi request

        Nothing ->
            Cmd.none


claimFlameThrower : Maybe String -> Cmd Msg
claimFlameThrower claimTicket =
    case claimTicket of
        Just ticket ->
            let
                url =
                    "http://kubernetes.strocamp.net:8888/flamer/claim"

                request =
                    Http.request
                        { method = "POST"
                        , url = url
                        , headers = []
                        , body = claimEncoder ticket |> Http.jsonBody
                        , timeout = Nothing
                        , expect = Http.expectJson claimDecoder
                        , withCredentials = False
                        }
            in
                Http.send CallFlameThrowerClaim request

        Nothing ->
            Cmd.none


fireFlameThrower : Maybe String -> Int -> Cmd Msg
fireFlameThrower claimTicket action =
    case claimTicket of
        Just ticket ->
            let
                url =
                    "http://kubernetes.strocamp.net:8888/flamer/fire"

                request =
                    Http.request
                        { method = "POST"
                        , url = url
                        , headers = []
                        , body = fireEncoder ticket action |> Http.jsonBody
                        , timeout = Nothing
                        , expect = Http.expectJson claimDecoder
                        , withCredentials = False
                        }
            in
                Http.send CallFlameThrowerFire request

        Nothing ->
            Cmd.none


claimEncoder : String -> Json.Encode.Value
claimEncoder ticket =
    let
        attributes =
            [ ( "claimTicket", Json.Encode.string ticket ) ]
    in
        Json.Encode.object attributes


fireEncoder : String -> Int -> Json.Encode.Value
fireEncoder ticket action =
    let
        attributes =
            [ ( "claimTicket", Json.Encode.string ticket )
            , ( "action", Json.Encode.int action )
            ]
    in
        Json.Encode.object attributes



-- PORTS


port openDialog : (String -> msg) -> Sub msg


port setZones : List Zone -> Cmd msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ openDialog OpenColorPicker
        , Time.every Time.second Tick
        ]



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
