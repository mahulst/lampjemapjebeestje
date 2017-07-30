port module App exposing (..)

import Html
import Time
import View exposing (view)
import Model exposing (Model, Modals)
import Ports exposing (openDialog)
import Update exposing (..)
import Material


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ openDialog OpenColorPicker
        , Time.every Time.second Tick
        ]



---- PROGRAM ----


init : ( Model, Cmd Msg )
init =
    ( { message = ""
      , selectedZone = Nothing
      , showingModal = Model.None
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


main : Program Never Model Msg
main =
    Html.program
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
