module Model exposing (..)

import Json.Decode exposing (Decoder, at, string, bool, float, nullable, list)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode
import Material
import Time exposing (Time)
import Date


-- MODEL


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
    | FlameThrowerTemp
    | FlameThrowerTemp2
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



-- ENCODERS


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



-- DECODERS


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


decodeChooseColorResponse : Decoder String
decodeChooseColorResponse =
    at [ "data", "image_url" ] string



-- MODEL UTIL FUNCTIONS


redUpdater : Float -> Color -> Color
redUpdater val color =
    { color | red = val }


blueUpdater : Float -> Color -> Color
blueUpdater val color =
    { color | blue = val }


greenUpdater : Float -> Color -> Color
greenUpdater val color =
    { color | green = val }


redUpdaterInput : String -> Color -> Color
redUpdaterInput val color =
    let
        int =
            (Result.withDefault 0 (String.toFloat val))

        float =
            int / 255 * 100
    in
        { color | red = float }


blueUpdaterInput : String -> Color -> Color
blueUpdaterInput val color =
    let
        int =
            (Result.withDefault 0 (String.toFloat val))

        float =
            int / 255 * 100
    in
        { color | blue = float }


greenUpdaterInput : String -> Color -> Color
greenUpdaterInput val color =
    let
        int =
            (Result.withDefault 0 (String.toFloat val))

        float =
            int / 255 * 100
    in
        { color | green = float }


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
