module Main exposing (Model, Msg(..), init, main, subscriptions, update, view)

import Browser
import Html exposing (..)
import Html.Events exposing ( onClick )
import Task
import Time


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

type alias Model =
    { zone : Time.Zone
    , time : Time.Posix
    , proceed : Bool
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model Time.utc (Time.millisToPosix 0) True
    , Task.perform AdjustTimeZone Time.here
    )



-- UPDATE


type Msg
    = Tick Time.Posix
    | AdjustTimeZone Time.Zone
    | Stop
    | Resume


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Tick newTime ->
            ( { model | time = newTime }
            , Cmd.none
            )

        AdjustTimeZone newTimeZone ->
            ( { model | zone = newTimeZone }
            , Cmd.none
            )

        Stop ->
            ( { model | proceed = False }
            , Cmd.none
            )

        Resume ->
            ( { model | proceed = True }
            , Cmd.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  case model.proceed of
    True ->
      Time.every 1000 Tick

    False ->
      Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    let
        hour =
            String.fromInt (Time.toHour model.zone model.time)

        min =
            String.fromInt (Time.toMinute model.zone model.time)

        sec =
            String.fromInt (Time.toSecond model.zone model.time)
    in
    div []
        [ h1 [] [ Html.text (hour ++ " : " ++ min ++ " : " ++ sec) ]
        , button [ onClick Stop] [ text "Stop clock!"]
        , button [ onClick Resume] [text "Resume"]
        ]
