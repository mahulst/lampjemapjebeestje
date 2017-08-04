module Update exposing (..)

import Time exposing (Time, second)
import Material
import Model exposing (..)
import Http exposing (Error)
import Ports exposing (..)
import Task


type Msg
    = OpenColorPicker String
    | ClaimTicketTime Time
    | Tick Time
    | OpenInfo
    | OpenFlameThrower
    | OpenFlameThrowerClaim
    | OpenFlameThrowerFire
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
    | InputRed String
    | InputBlue String
    | InputGreen String
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
                    ( { model | currentTime = newTime, claimedFlameThrower = False, claimTicket = Nothing, claimTicketTime = Nothing }, Cmd.none )
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

        OpenFlameThrowerClaim ->
            ( { model | showingModal = FlameThrowerTemp }, Cmd.none )

        OpenFlameThrowerFire ->
            ( { model | showingModal = FlameThrowerTemp2 }, Cmd.none )

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

        InputRed val ->
            ( { model | color = (redUpdaterInput val model.color) }, Cmd.none )

        InputBlue val ->
            ( { model | color = (blueUpdaterInput val model.color) }, Cmd.none )

        InputGreen val ->
            ( { model | color = (greenUpdaterInput val model.color) }, Cmd.none )



-- API CALLS


chooseColor : Maybe String -> Color -> Cmd Msg
chooseColor selectedZone color =
    case selectedZone of
        Just selectedZone ->
            let
                url =
                    "http://172.23.20.202:8888/zones/" ++ selectedZone ++ "/claim"

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
                    "http://172.23.20.202:8888/flamer/claim"

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
                    "http://172.23.20.202:8888/flamer/fire"

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


getZones : Cmd Msg
getZones =
    Http.send
        GetZones
        (Http.get ("http://172.23.20.202:8888/zones/") zonesDecoder)
