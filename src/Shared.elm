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


type alias Identity =
    String


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


makeRequest : Cmd Msg
makeRequest =
    query
        |> Graphql.Http.queryRequest "/api"
        |> Graphql.Http.send (RemoteData.fromResult >> GotResponse)


type alias Shared =
    { key : Nav.Key
    , identity : Maybe Identity
    , todos : RemoteData (Graphql.Http.Error TodoPageResponse) TodoPageResponse
    }


type Msg
    = SetIdentity Identity (Maybe String)
    | ResetIdentity
    | ReplaceRoute Route
    | GotResponse (RemoteData (Graphql.Http.Error TodoPageResponse) TodoPageResponse)


identity : Shared -> Maybe String
identity =
    .identity


init : () -> Nav.Key -> ( Shared, Cmd Msg )
init _ key =
    ( { key = key
      , identity = Nothing
      , todos = RemoteData.NotAsked
      }
    , makeRequest
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

        GotResponse response ->
            ( { shared | todos = response }, Cmd.none )


subscriptions : Shared -> Sub Msg
subscriptions =
    always Sub.none


setIdentity : String -> Maybe String -> Msg
setIdentity =
    SetIdentity


replaceRoute : Route -> Msg
replaceRoute =
    ReplaceRoute
