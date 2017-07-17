port module App exposing (..)

import Html exposing (Html, text, div, img)
import Html.Attributes exposing (src, class)
import Html.Events exposing (onClick)
import Http exposing (Error)
import Json.Decode exposing (Decoder, at, string)

---- MODEL ----


type alias Model =
    { message : String
    , logo : String
    , showingModal: Bool
    }


init : String -> ( Model, Cmd Msg )
init path =
    ( { message = "Your Elm App is working!", logo = path, showingModal = True }, Cmd.none )



---- UPDATE ----


type Msg
    = OpenDialog String
    | CloseDialog
    | ChooseColor
    | CallApi (Result Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        (OpenDialog string) ->
            ( { model | message = string, showingModal = True }, Cmd.none )

        CloseDialog ->
            ( { model | showingModal = False }, Cmd.none )

        ChooseColor ->
            ( model, chooseColor "lamp 1" )

        CallApi (Ok json) ->
            ( model, Cmd.none )

        CallApi (Err _) ->
            ( model, Cmd.none )


---- VIEW ----


view : Model -> Html Msg
view model =
  case model.showingModal of
      True -> modal model

      False -> noModal

modal : Model -> Html Msg
modal model =
    div [ class "modal" ]
        [ text "this is a modal"
        , div [ onClick CloseDialog ] [text "close"]
        , callForApi model
        ]

noModal : Html Msg
noModal = div [] [ text "no modal" ]

callForApi : Model -> Html Msg
callForApi model =
  div [onClick ChooseColor ] [ text "Call api" ]

chooseColor : String -> Cmd Msg
chooseColor lamp =
  let
    url =
      "https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ lamp

    request =
      Http.get url decodeChooseColorResponse
  in
    Http.send CallApi request


decodeChooseColorResponse : Decoder String
decodeChooseColorResponse =
  at ["data", "image_url"] string

-- PORTS


port openDialog : (String -> msg) -> Sub msg


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    openDialog OpenDialog



---- PROGRAM ----


main : Program String Model Msg
main =
    Html.programWithFlags
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
