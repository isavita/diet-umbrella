module Main exposing (Msg(..), initModel, main, update, view)

import Browser exposing (sandbox)
import Html exposing (button, div, text)
import Html.Events exposing (onClick)


main =
    sandbox { init = initModel, view = view, update = update }


initModel =
    0


type Msg
    = Increment
    | Decrement


update msg model =
    case msg of
        Increment ->
            model + 1

        Decrement ->
            if model > 0 then
                model - 1

            else
                0


view model =
    div []
        [ button [ onClick Decrement ] [ text "-" ]
        , div [] [ text (String.fromInt model) ]
        , button [ onClick Increment ] [ text "+" ]
        ]
