module Main exposing (main)

import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Pages.About as About
import Pages.Home as Home
import Pages.Time as Time
import Pages.Todos as Counter
import Route
import Shared exposing (Shared)
import Spa
import View exposing (View)


mappers : ( (a -> b) -> View a -> View b, (c -> d) -> View c -> View d )
mappers =
    ( View.map, View.map )


toDocument :
    Shared
    -> View (Spa.Msg Shared.Msg pageMsg)
    -> Document (Spa.Msg Shared.Msg pageMsg)
toDocument shared view =
    { title = view.title
    , body =
        [ div [ class "flex justify-between items-center p-2" ]
            [ div
                [ class "flex items-center gap-4" ]
                [ img [ src "/logo.png", class "w-12" ] []
                , h1 [] [ text "Elm Netlify Todos" ]
                ]
            , nav [ class "flex gap-4 text-lg font-bold" ]
                [ a [ href "/" ] [ text "Home" ]
                , a [ href "/about" ] [ text "About" ]
                , case shared.currentUser of
                    Just _ ->
                        a [ href "/todos" ] [ text "Todos" ]

                    Nothing ->
                        text ""
                , div
                    []
                  <|
                    case shared.currentUser of
                        Just currentUser ->
                            [ text currentUser.name
                            , text " | "
                            , a [ href "#", onClick (Spa.mapSharedMsg Shared.Logout) ] [ text "Log out" ]
                            ]

                        Nothing ->
                            [ a [ href "#", onClick (Spa.mapSharedMsg Shared.OpenLogin) ] [ text "Sign in" ] ]
                ]
            ]
        , main_
            []
            [ view.body ]
        ]
    }


main =
    Spa.init
        { defaultView = View.defaultView
        , extractIdentity =
            .currentUser
        }
        |> Spa.addPublicPage mappers Route.matchHome Home.page
        |> Spa.addPublicPage mappers Route.matchAbout About.page
        |> Spa.addProtectedPage mappers Route.matchCounter Counter.page
        |> Spa.addPublicPage mappers Route.matchTime Time.page
        |> Spa.application View.map
            { init = Shared.init
            , subscriptions = Shared.subscriptions
            , update = Shared.update
            , toRoute = Route.toRoute
            , toDocument = toDocument
            , protectPage = \_ -> Route.toUrl Route.Home
            }
        |> Browser.application
