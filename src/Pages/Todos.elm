module Pages.Todos exposing (Model, Msg(..), init, page, update, view)

import Api
import Effect exposing (Effect)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import RemoteData exposing (RemoteData(..))
import Shared exposing (Shared)
import Spa.Page
import Todo
import View exposing (View)


page : Shared -> Shared.User -> Spa.Page.Page () Shared.Msg (View Msg) Model Msg
page _ user =
    Spa.Page.element
        { init = init user
        , update = update
        , subscriptions = always Sub.none
        , view = view
        }


type Msg
    = ReceiveAllTodos Todo.TodoQuery


type alias Model =
    { todos : Todo.TodoQuery }


init : Shared.User -> () -> ( Model, Effect Shared.Msg Msg )
init user _ =
    { todos = NotAsked } |> Effect.withCmd (Api.request Todo.allTodos (Just user.token) ReceiveAllTodos)


update : Msg -> Model -> ( Model, Effect Shared.Msg Msg )
update msg model =
    case msg of
        ReceiveAllTodos response ->
            { model | todos = response } |> Effect.withNone


view : Model -> View Msg
view model =
    { title = "Counter"
    , body =
        div []
            [ h1 [ class "text-2xl" ] [ text "Todos" ]
            , case model.todos of
                NotAsked ->
                    text "Not asked to get anything"

                Loading ->
                    text "Loading..."

                Success todos ->
                    ul [] (todos.data |> List.map (\todo -> li [] [ text todo.title ]))

                Failure _ ->
                    text "ruh roh."
            ]
    }
