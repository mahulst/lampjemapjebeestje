module View exposing (view)

import Model exposing (..)
import Update exposing (..)
import Html exposing (Html, text, div, img, input, span, node, a, h1, p)
import Html.Attributes as H exposing (src, class, type_, classList)
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
            , div [ class "modal" ]
                [ div [ class "header" ]
                    [ div [ onClick CloseDialog, class "close" ]
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
    div [ class "cmsha-btn" ]
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
        [ h1 [] [ text "Info" ]
        , p [] [ text "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. " ]
        ]


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
        , div [ classList [ ( "fire", True ), ( "active", fireIsActive ) ], onClick OpenFlameThrower ]
            [ a [ H.href "#" ]
                [ node "i" [ class "fa fa-fire" ] [] ]
            ]
        , div [ class "info", onClick OpenInfo ]
            [ a []
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


slider : Float -> (Float -> Msg) -> String -> Html Msg
slider float msg title =
    div []
        [ text title
        , Slider.view
            [ Slider.onChange msg
            , Slider.value float
            ]
        ]
