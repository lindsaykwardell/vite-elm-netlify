module Pages.Todos exposing (Model, Msg(..), init, page, update, view)

import Api
import Effect exposing (Effect)
import Graphql.Http
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import List.Extra as List
import RemoteData exposing (RemoteData(..))
import Shared exposing (Shared)
import Spa.Page
import Todo exposing (Todo)
import View exposing (View)


page : Shared -> Shared.User -> Spa.Page.Page () Shared.Msg (View Msg) Model Msg
page shared user =
    Spa.Page.element
        { init = init user
        , update = update shared
        , subscriptions = always Sub.none
        , view = view
        }


type Msg
    = ReceiveAllTodos (Api.Query Todo.TodoPage)
    | UpdateTodo Todo
    | ReceiveUpdatedTodo (Api.Query (Maybe Todo))


type alias Model =
    { todos : Api.Query Todo.TodoPage }


init : Shared.User -> () -> ( Model, Effect Shared.Msg Msg )
init user _ =
    { todos = NotAsked } |> Effect.withCmd (Api.query Todo.allTodos (Just user.token) ReceiveAllTodos)


update : Shared -> Msg -> Model -> ( Model, Effect Shared.Msg Msg )
update shared msg model =
    case msg of
        ReceiveAllTodos response ->
            { model | todos = response } |> Effect.withNone

        UpdateTodo todo ->
            { model
                | todos =
                    model.todos |> RemoteData.map (\{ data } -> { data = data |> List.updateIf (.id >> (==) todo.id) (\_ -> todo) })
            }
                |> Effect.withCmd (Api.mutate (Todo.updateTodo todo) (shared.currentUser |> Maybe.map .token) ReceiveUpdatedTodo)

        ReceiveUpdatedTodo response ->
            model |> Effect.withNone


view : Model -> View Msg
view model =
    { title = "Counter"
    , body =
        div []
            [ h1 [] [ text "Todos" ]
            , case model.todos of
                NotAsked ->
                    text "Not asked to get anything"

                Loading ->
                    text "Loading..."

                Success todos ->
                    ul [] (todos.data |> List.map viewTodo)

                Failure _ ->
                    text "ruh roh."
            ]
    }


viewTodo : Todo -> Html Msg
viewTodo todo =
    li [ class "flex" ]
        [ label [ class "flex gap-2" ]
            [ input [ type_ "checkbox", class "accent-teal-500", checked todo.completed, onCheck (\completed -> UpdateTodo { todo | completed = completed }) ] []
            , text todo.title
            ]
        ]
