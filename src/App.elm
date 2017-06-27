port module App exposing (..)

import Html exposing (Html, text, div, img)
import Html.Attributes exposing (src)


---- MODEL ----


type alias Model =
    { message : String
    , logo : String
    }


init : String -> ( Model, Cmd Msg )
init path =
    ( { message = "Your Elm App is working!", logo = path }, Cmd.none )



---- UPDATE ----


type Msg
    = OpenDialog String


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        (OpenDialog string) ->
            ( { model | message = string }, Cmd.none )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ img [ src model.logo ] []
        , div [] [ text model.message ]
        ]



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
