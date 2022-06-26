module Todo exposing (..)

import Api.Mutation as Mutation
import Api.Object
import Api.Object.Todo as Todo
import Api.Object.TodoPage as TodoPage
import Api.Query as Query
import Api.ScalarCodecs as Scalar
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import RemoteData exposing (RemoteData(..))


type alias TodoPage =
    { data : List Todo
    }


type alias Todo =
    { id : Scalar.Id
    , title : String
    , completed : Bool
    }


allTodos : SelectionSet TodoPage RootQuery
allTodos =
    Query.allTodos (\opt -> opt) todoPage


todoPage : SelectionSet TodoPage Api.Object.TodoPage
todoPage =
    SelectionSet.succeed TodoPage
        |> SelectionSet.with (TodoPage.data todo |> SelectionSet.nonNullElementsOrFail)


todo : SelectionSet Todo Api.Object.Todo
todo =
    SelectionSet.succeed Todo
        |> SelectionSet.with Todo.id_
        |> SelectionSet.with Todo.title
        |> SelectionSet.with (Todo.completed |> SelectionSet.withDefault False)


updateTodo : Todo -> SelectionSet (Maybe Todo) RootMutation
updateTodo t =
    Mutation.updateTodo { id = t.id, data = { title = t.title, completed = Present t.completed } } todo
