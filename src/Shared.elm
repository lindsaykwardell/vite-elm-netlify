port module Shared exposing
    ( CurrentUser(..)
    , Msg(..)
    , Shared
    , User
    , init
    , replaceRoute
    , subscriptions
    , update
    )

import Browser.Navigation as Nav
import RemoteData exposing (RemoteData)
import Route exposing (Route)


type CurrentUser
    = SignedOut
    | SignedIn User


type alias User =
    { name : String
    , token : String
    }


type alias Shared =
    { key : Nav.Key
    , currentUser : CurrentUser
    }


type Msg
    = SetCurrentUser CurrentUser
    | ReplaceRoute Route
    | OpenLogin
    | Logout


init : () -> Nav.Key -> ( Shared, Cmd Msg )
init _ key =
    ( { key = key
      , currentUser =
            SignedOut
      }
    , Cmd.none
    )


update : Msg -> Shared -> ( Shared, Cmd Msg )
update msg shared =
    case msg of
        SetCurrentUser currentUser ->
            ( { shared | currentUser = currentUser }, Cmd.none )

        ReplaceRoute route ->
            ( shared, Nav.replaceUrl shared.key <| Route.toUrl route )

        OpenLogin ->
            ( shared, openLogin () )

        Logout ->
            ( { shared | currentUser = SignedOut }, Cmd.batch [ logout (), Nav.replaceUrl shared.key "/" ] )


subscriptions : Shared -> Sub Msg
subscriptions _ =
    Sub.batch
        [ receiveUser (\user -> SetCurrentUser (SignedIn user))
        ]


replaceRoute : Route -> Msg
replaceRoute =
    ReplaceRoute


port openLogin : () -> Cmd msg


port logout : () -> Cmd msg


port receiveUser : (User -> msg) -> Sub msg
