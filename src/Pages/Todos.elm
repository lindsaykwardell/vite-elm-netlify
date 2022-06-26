module Pages.Todos exposing (Model, Msg(..), init, page, update, view)

import Api
import Api.Scalar exposing (Id(..))
import Debouncer.Basic as Debouncer exposing (Debouncer)
import Dict exposing (Dict)
import Effect exposing (Effect)
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
    | SaveTodo Todo
    | DebounceTodo Todo (Debouncer.Msg Msg)
    | ReceiveUpdatedTodo (Api.Query (Maybe Todo))
    | AddTodo
    | ReceiveNewTodo (Api.Query Todo)
    | DeleteTodo Todo
    | ReceiveDeletedTodo (Api.Query (Maybe Todo))


type alias Model =
    { todos : Api.Query Todo.TodoPage, debounce : Dict String (Debouncer Msg Msg) }


init : Shared.User -> () -> ( Model, Effect Shared.Msg Msg )
init user _ =
    { todos = NotAsked, debounce = Dict.empty } |> Effect.withCmd (Api.query Todo.allTodos (Just user.token) ReceiveAllTodos)


newDebouncer : Debouncer Msg Msg
newDebouncer =
    Debouncer.manual
        |> Debouncer.settleWhenQuietFor (Just <| Debouncer.fromSeconds 1)
        |> Debouncer.toDebouncer


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
                |> update shared (DebounceTodo todo (Debouncer.provideInput <| SaveTodo todo))

        SaveTodo todo ->
            model |> Effect.withCmd (Api.mutate (Todo.updateTodo todo) (shared.currentUser |> Maybe.map .token) ReceiveUpdatedTodo)

        DebounceTodo todo subMsg ->
            let
                todoId =
                    todo.id |> (\(Id id) -> id)
            in
            case Dict.get todoId model.debounce |> Maybe.map (Debouncer.update subMsg) of
                Just ( subModel, subCmd, emittedMsg ) ->
                    let
                        mappedCmd =
                            Cmd.map (DebounceTodo todo) subCmd

                        updatedModel =
                            { model | debounce = Dict.insert todoId subModel model.debounce }
                    in
                    case emittedMsg of
                        Just emitted ->
                            update shared emitted updatedModel
                                |> Effect.addCmd mappedCmd

                        Nothing ->
                            updatedModel |> Effect.withCmd mappedCmd

                Nothing ->
                    { model | debounce = Dict.insert todoId newDebouncer model.debounce } |> update shared (DebounceTodo todo subMsg)

        ReceiveUpdatedTodo _ ->
            model |> Effect.withNone

        AddTodo ->
            model |> Effect.withCmd (Api.mutate Todo.addTodo (shared.currentUser |> Maybe.map .token) ReceiveNewTodo)

        ReceiveNewTodo result ->
            { model
                | todos =
                    case ( model.todos, result ) of
                        ( Success todos, Success todo ) ->
                            Success { data = todos.data |> List.reverse |> (::) todo |> List.reverse }

                        _ ->
                            model.todos
            }
                |> Effect.withNone

        DeleteTodo todo ->
            { model
                | todos =
                    case model.todos of
                        Success todos ->
                            Success { data = todos.data |> List.filter (.id >> (/=) todo.id) }

                        _ ->
                            model.todos
            }
                |> Effect.withCmd (Api.mutate (Todo.deleteTodo todo) (shared.currentUser |> Maybe.map .token) ReceiveDeletedTodo)

        ReceiveDeletedTodo _ ->
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
                    div []
                        [ ul [ class "py-3" ] (todos.data |> List.map viewTodo)
                        , button [ class "bg-blue-500 p-1 hover:bg-blue-700 transition duration-75 rounded font-bold font-anek text-lg text-white", onClick AddTodo ] [ text "Add new todo" ]
                        ]

                Failure _ ->
                    text "ruh roh."
            ]
    }


viewTodo : Todo -> Html Msg
viewTodo todo =
    li [ class "flex gap-2 py-1" ]
        [ input
            [ type_ "checkbox"
            , class "accent-teal-500"
            , checked todo.completed
            , onCheck (\completed -> UpdateTodo { todo | completed = completed })
            ]
            []
        , input [ type_ "text", class "w-full p-1", value todo.title, onInput (\title -> UpdateTodo { todo | title = title }) ] []
        , button [ class "w-8 h-8 border border-red-300 hover:border-red-500 hover:bg-red-100 transition duration-75 rounded border-2", onClick (DeleteTodo todo) ] [ text "🗑" ]
        ]
