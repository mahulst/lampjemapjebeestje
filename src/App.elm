port module App exposing (..)

import Html exposing (Html, text, div, img, input)
import Html.Attributes as H exposing (src, class, type_)
import Html.Events exposing (onClick, onInput)
import Http exposing (Error)
import Json.Decode exposing (Decoder, at, string)
import Http
import Json.Encode
import Material.Slider as Slider
import Material.Button as Button
import Material.Options as Options
import Material
import Material.Icon as Icon


---- MODEL ----


type alias Model =
    { message : String
    , lamp : String
    , showingModal : Modals
    , color : Color
    , mdl : Material.Model
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


init : ( Model, Cmd Msg )
init =
    ( { message = "", lamp = "", showingModal = None, color = { red = 50, blue = 50, green = 50 }, mdl = Material.model }, Cmd.none )



---- UPDATE ----


type Msg
    = OpenColorPicker String
    | OpenInfo
    | CloseDialog
    | ChooseColor
    | CallApi (Result Error String)
    | UpdateRed Float
    | UpdateBlue Float
    | UpdateGreen Float
    | Mdl (Material.Msg Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Mdl msg_ ->
            Material.update Mdl msg_ model

        OpenColorPicker string ->
            ( { model | lamp = string, showingModal = ColorPicker }, Cmd.none )

        OpenInfo ->
            ( { model | showingModal = Info }, Cmd.none )

        CloseDialog ->
            ( { model | showingModal = None, message = "" }, Cmd.none )

        ChooseColor ->
            ( model, chooseColor "test" model.color )

        CallApi (Ok json) ->
            ( { model | showingModal = None, message = "" }, Cmd.none )

        CallApi (Err _) ->
            ( { model | message = "Could not claim this light, already claimed" }, Cmd.none )

        UpdateRed val ->
            let
                color =
                    model.color

                newColor =
                    { color | red = val }
            in
                ( { model | color = newColor }, Cmd.none )

        UpdateBlue val ->
            let
                color =
                    model.color

                newColor =
                    { color | blue = val }
            in
                ( { model | color = newColor }, Cmd.none )

        UpdateGreen val ->
            let
                color =
                    model.color

                newColor =
                    { color | green = val }
            in
                ( { model | color = newColor }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    case model.showingModal of
        ColorPicker ->
            modal model (modalColorPicker model)

        Info ->
            modal model modalInfo

        FlameThrower ->
            div [] [ navbar ]

        None ->
            div [] [ navbar ]


modal : Model -> Html Msg -> Html Msg
modal model content =
    div []
        [ navbar
        , div [ class "modal" ]
            [ div [ class "header" ]
                [ div [ onClick CloseDialog, class "close" ] [ Icon.i "close" ] ]
            , content
            ]
        ]


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


navbar : Html Msg
navbar =
    div [ class "nav" ]
        [ div [ class "title" ] [ text "ColourMySha" ]
        , div [ class "fire" ] [ Icon.i "warning" ]
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


chooseColor : String -> Color -> Cmd Msg
chooseColor lamp color =
    let
        url =
            "http://kubernetes.strocamp.net:8888/zones/" ++ lamp ++ "/claim"

        headers =
            [ (Http.header "X-Auth-ApiKey" "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJDb2xvck15U0hBMjAxNyIsInN1YiI6IktleUZvclNsYWNrRGlzdHJpYnV0aW9uIiwibmJmIjoxNDk5NjE4ODU2LCJleHAiOjE1MzExNTQ4NTYsImlhdCI6MTQ5OTYxODg1NiwianRpIjoiaWQ0MiIsInR5cCI6Imh0dHBzOi8va3ViZXJuZXRlcy5zdHJvY2FtcC5uZXQifQ.KoJy4eYMt5o9opSRlXmnTOx0jyBVGhq1ksUMs5-PRsqug3Fp60tctZnavHQDxTeBe-xwGfV_4G_gc3uXUKCqdD58FMVa6KoAB4kP-Fn1i-93RNgKYONceZo_rplreLa3T7wAjtFWnlPG0RC4etfRjSU904LJFfH2yCGeXDKDmukZ07w98VxMYWlNVWZdK7C55N4eUwSh_eo89wgISxJpI9lNOg89ZCEXTcTBcwnlQRqwSObLZ1r8OVfTcKSfMxXX5sFD6RlP06c7TtsDjBMxQ9_fcdfh6d7l4VqMuMwUrENrmsNc8iO7ZnHfNQoIjiBQsqE5CHSxisV0AP6DoR_R9Uq91TiQCxstdJ2rgZOIPJO8IlFP7Xw5eOdA1pJlry9pUBftMdMhsDHimzcPrVJRHzYmwQ38NLSWs9uOf1DGX8iF8HeGrzw3oDEFJyqaeb1sEOAxBrPI9YCshpCxqse-sfN7WRtAb9zCqJSBe1R-hs0sxhexgjSS1s9GTD2Hp6icbcEFNV_8m8KbYVgX_B6yIAiDXyJadSH7cc60T40Ji34LBvCai_kts37jSNnWVa-FkTAxpN5_PqVTTmPYlmPPltAA-u4x78KVZDAiqlhSvB75LgS0Hxrn73QAlYcI4Gp5kXHO_PNjw1Ocv73LSKzg6ObbMMqnrCz-YIIBUKAY17s") ]

        request =
            Http.request
                { method = "PUT"
                , url = url
                , headers = headers
                , body = colorEncoder color |> Http.jsonBody
                , timeout = Nothing
                , expect = Http.expectJson decodeChooseColorResponse
                , withCredentials = False
                }
    in
        Http.send CallApi request



-- PORTS


port openDialog : (String -> msg) -> Sub msg



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    openDialog OpenColorPicker



---- PROGRAM ----


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
