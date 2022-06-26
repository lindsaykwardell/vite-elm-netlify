port module Shared exposing
    ( CurrentUser(..)
    , Msg(..)
    , Shared
    , TodoPageResponse
    , TodoResponse
    , User
    , init
    , replaceRoute
    , subscriptions
    , update
    )

import Api
import Api.Object
import Api.Object.Todo as Todo
import Api.Object.TodoPage as TodoPage
import Api.Query as Query
import Browser.Navigation as Nav
import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import RemoteData exposing (RemoteData)
import Route exposing (Route)


type CurrentUser
    = SignedOut
    | SignedIn User


type alias User =
    { name : String
    }


type alias TodoPageResponse =
    { data : List (Maybe TodoResponse)
    }


type alias TodoResponse =
    { title : String
    , completed : Bool
    }


query : SelectionSet TodoPageResponse RootQuery
query =
    Query.allTodos (\opt -> opt) todoPage


todoPage : SelectionSet TodoPageResponse Api.Object.TodoPage
todoPage =
    SelectionSet.succeed TodoPageResponse
        |> SelectionSet.with (TodoPage.data todos)


todos : SelectionSet TodoResponse Api.Object.Todo
todos =
    SelectionSet.succeed TodoResponse
        |> SelectionSet.with Todo.title
        |> SelectionSet.with (Todo.completed |> SelectionSet.withDefault False)


type alias Shared =
    { key : Nav.Key
    , currentUser : CurrentUser
    , todos : RemoteData (Graphql.Http.Error TodoPageResponse) TodoPageResponse
    }


type Msg
    = SetCurrentUser CurrentUser
    | ReplaceRoute Route
    | OpenLogin
    | Logout
    | GotResponse (RemoteData (Graphql.Http.Error TodoPageResponse) TodoPageResponse)


init : () -> Nav.Key -> ( Shared, Cmd Msg )
init _ key =
    ( { key = key
      , currentUser =
            SignedOut
      , todos = RemoteData.NotAsked
      }
    , Api.request query GotResponse
    )


update : Msg -> Shared -> ( Shared, Cmd Msg )
update msg shared =
    case msg of
        SetCurrentUser currentUser ->
            ( { shared | currentUser = currentUser }, Nav.replaceUrl shared.key "/" )

        ReplaceRoute route ->
            ( shared, Nav.replaceUrl shared.key <| Route.toUrl route )

        OpenLogin ->
            ( shared, openLogin () )

        Logout ->
            ( { shared | currentUser = SignedOut }, Cmd.batch [ logout (), Nav.replaceUrl shared.key "/" ] )

        GotResponse response ->
            ( { shared | todos = response }, Cmd.none )


subscriptions : Shared -> Sub Msg
subscriptions shared =
    Sub.batch
        [ receiveUser (\user -> SetCurrentUser (SignedIn user))
        ]


replaceRoute : Route -> Msg
replaceRoute =
    ReplaceRoute


port openLogin : () -> Cmd msg


port logout : () -> Cmd msg


port receiveUser : (User -> msg) -> Sub msg
