port module Ports exposing (..)

import Model exposing (Zone)


-- PORTS


port openDialog : (String -> msg) -> Sub msg


port setZones : List Zone -> Cmd msg
