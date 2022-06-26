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

        ReceiveUpdatedTodo response ->
            let
                _ =
                    Debug.log "got it back" response
            in
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
