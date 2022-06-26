module Todo exposing (..)

import Api.Object
import Api.Object.Todo as Todo
import Api.Object.TodoPage as TodoPage
import Api.Query as Query
import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import RemoteData exposing (RemoteData(..))


type alias TodoPage =
    { data : List Todo
    }


type alias Todo =
    { title : String
    , completed : Bool
    }


type alias TodoQuery =
    RemoteData (Graphql.Http.Error TodoPage) TodoPage


allTodos : SelectionSet TodoPage RootQuery
allTodos =
    Query.allTodos (\opt -> opt) todoPage


todoPage : SelectionSet TodoPage Api.Object.TodoPage
todoPage =
    SelectionSet.succeed TodoPage
        |> SelectionSet.with (TodoPage.data todos |> SelectionSet.nonNullElementsOrFail)


todos : SelectionSet Todo Api.Object.Todo
todos =
    SelectionSet.succeed Todo
        |> SelectionSet.with Todo.title
        |> SelectionSet.with (Todo.completed |> SelectionSet.withDefault False)
