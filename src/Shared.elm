module Shared exposing
    ( Identity
    , Msg(..)
    , Shared
    , identity
    , init
    , replaceRoute
    , setIdentity
    , subscriptions
    , update
    )

import Browser.Navigation as Nav
import Http
import Json.Decode as Decode
import Json.Decode.Pipeline as Decode
import Route exposing (Route)


type alias Identity =
    String


type alias HelloWorldPayload =
    { message : String }


helloWorldPayloadDecoder : Decode.Decoder HelloWorldPayload
helloWorldPayloadDecoder =
    Decode.succeed HelloWorldPayload
        |> Decode.required "message" Decode.string


type RemoteData a e
    = NotAsked
    | Loading
    | Success a
    | Error e


type alias Shared =
    { key : Nav.Key
    , identity : Maybe Identity
    , helloWorld : RemoteData HelloWorldPayload Http.Error
    }


type Msg
    = SetIdentity Identity (Maybe String)
    | ResetIdentity
    | ReplaceRoute Route
    | ReceiveHelloWorld (Result Http.Error HelloWorldPayload)


identity : Shared -> Maybe String
identity =
    .identity


init : () -> Nav.Key -> ( Shared, Cmd Msg )
init _ key =
    ( { key = key
      , identity = Nothing
      , helloWorld = Loading
      }
    , Http.get { url = "/.netlify/functions/hello-world?name=Bob Day", expect = Http.expectJson ReceiveHelloWorld helloWorldPayloadDecoder }
    )


update : Msg -> Shared -> ( Shared, Cmd Msg )
update msg shared =
    case msg of
        SetIdentity newIdentity redirect ->
            ( { shared | identity = Just newIdentity }
            , redirect
                |> Maybe.map (Nav.replaceUrl shared.key)
                |> Maybe.withDefault Cmd.none
            )

        ResetIdentity ->
            ( { shared | identity = Nothing }, Cmd.none )

        ReplaceRoute route ->
            ( shared, Nav.replaceUrl shared.key <| Route.toUrl route )

        ReceiveHelloWorld result ->
            case result of
                Ok payload ->
                    ( { shared | helloWorld = Success payload }, Cmd.none )

                Err err ->
                    ( { shared | helloWorld = Error err }, Cmd.none )


subscriptions : Shared -> Sub Msg
subscriptions =
    always Sub.none


setIdentity : String -> Maybe String -> Msg
setIdentity =
    SetIdentity


replaceRoute : Route -> Msg
replaceRoute =
    ReplaceRoute
