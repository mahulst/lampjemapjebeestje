module View exposing (view)

import Model exposing (..)
import Update exposing (..)
import Html exposing (Html, text, div, img, input, span, node, a, h1, p)
import Html.Attributes as H exposing (src, class, type_, classList, title)
import Html.Events exposing (onClick, onInput)
import Material.Slider as Slider
import Material.Button as Button
import Material.Options as Options


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
            , div [ classList [ ( "modal", True ), ( "play", model.claimedFlameThrower ), ( "claim", model.claimTicket /= Nothing && model.claimedFlameThrower == False ) ] ]
                [ div [ class "header" ]
                    [ div [ onClick CloseDialog, class "close", title "Close" ]
                        [ a []
                            [ node "i" [ class "fa fa-close" ] [] ]
                        ]
                    ]
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
            div [ class "claim" ]
                [ h1 [] [ text "ColourMySha Light Hacking" ]
                , p [] [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. " ]
                , timer (round ((time - model.currentTime) / 1000))
                , claimFlamethrowerButton model
                ]

        Nothing ->
            div [] [ h1 [] [ text "Flame Towers" ], p [] [ text "When you're around the Flame Tower at X location, you automatically take part in the fire lottery. Every hour a guest will be chosen." ] ]


timeToPlayWithFlameThrower : Model -> Html Msg
timeToPlayWithFlameThrower model =
    case model.claimTicketTime of
        Just time ->
            div [ class "play" ]
                [ h1 [] [ text "ColourMySha Light Hacking" ]
                , p [] [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt." ]
                , timer (round ((time - model.currentTime) / 1000))
                , div [ class "fire-buttons" ]
                    [ playWithFlamethrowerButton model 1
                    , playWithFlamethrowerButton model 2
                    , playWithFlamethrowerButton model 3
                    , playWithFlamethrowerButton model 4
                    ]
                ]

        Nothing ->
            div [] [ text "Can not fire flamethrower right now" ]


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
    div [ class "cmsha-btn fire" ]
        [ Button.render Mdl
            [ 0 ]
            model.mdl
            [ Button.raised
            , Button.ripple
            , Options.onClick (FireFlameThrower action)
            ]
            [ text ("Fire " ++ (toString action)) ]
        ]


claimFlamethrowerButton : Model -> Html Msg
claimFlamethrowerButton model =
    div [ class "cmsha-btn" ]
        [ Button.render Mdl
            [ 0 ]
            model.mdl
            [ Button.raised
            , Button.ripple
            , Options.onClick ClaimFlameThrower
            ]
            [ text "Claim" ]
        ]


modalInfo : Html Msg
modalInfo =
    div []
        [ h1 [] [ text "ColourMySha Light Hacking" ]
        , p [] [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. " ]
        ]


modalColorPicker : Model -> Html Msg
modalColorPicker model =
    let
        zoneName =
            case model.selectedZone of
                Just n ->
                    n

                Nothing ->
                    "<Not found>"
    in
        div [ class "content" ]
            [ h1 [] [ text zoneName ]
            , p [] [ text "Change the colour, using the sliders below. Your chosen colour will remain during 10 minutes." ]
            , preview model.color
            , div [ class "sliders" ]
                [ slider model.color.red UpdateRed InputRed "Red"
                , slider model.color.blue UpdateBlue InputBlue "Blue"
                , slider model.color.green UpdateGreen InputGreen "Green"
                ]
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
        [ a [ H.href "/" ] [ div [ class "title" ] [ text "ColourMySha" ] ]
        , div [ classList [ ( "fire", True ), ( "active", fireIsActive ) ], onClick OpenFlameThrower ]
            [ a [ H.href "#", title "Flame Tower" ]
                [ node "i" [ class "fa fa-fire" ] [] ]
            ]
        , div [ class "info", onClick OpenInfo ]
            [ a [ H.href "#", title "Info" ]
                [ node "i" [ class "fa fa-info" ] [] ]
            ]
        ]


callApiButton : Model -> Html Msg
callApiButton model =
    div [ class "cmsha-btn" ]
        [ Button.render Mdl
            [ 0 ]
            model.mdl
            [ Button.raised
            , Button.ripple
            , Options.onClick ChooseColor
            ]
            [ text "Set color" ]
        ]


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


slider : Float -> (Float -> Msg) -> (String -> Msg) -> String -> Html Msg
slider float sliderMsg inputMsg title =
    div
        []
        [ span [] [ text title ]
        , Slider.view
            [ Slider.onChange sliderMsg
            , Slider.value float
            ]
        , div [] [ input [ type_ "tel", onInput inputMsg, H.value (toString (round (float * 2.55))) ] [] ]
        ]
