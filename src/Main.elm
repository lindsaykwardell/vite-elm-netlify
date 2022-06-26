module Main exposing (main)

import Browser exposing (Document)
import Html exposing (a, button, div, text)
import Html.Attributes exposing (href, style)
import Html.Events exposing (onClick)
import Pages.About as About
import Pages.Counter as Counter
import Pages.Home as Home
import Pages.Time as Time
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
        [ div
            [ style "font-size" "20px" ]
            [ div
                [ style "width" "100%"
                , style "height" "100%"
                ]
                [ div
                    [ style "text-align" "right"
                    , style "padding" "20px"
                    ]
                  <|
                    case shared.currentUser of
                        Shared.SignedIn currentUser ->
                            [ text currentUser.name
                            , text " | "
                            , a [ href "#", onClick (Spa.mapSharedMsg Shared.Logout) ] [ text "Log out" ]
                            ]

                        Shared.SignedOut ->
                            [ a [ href "#", onClick (Spa.mapSharedMsg Shared.OpenLogin) ] [ text "Sign in" ] ]
                , div
                    [ style "display" "flex"
                    , style "align-items" "center"
                    , style "justify-content" "center"
                    ]
                    [ view.body ]
                ]
            ]
        ]
    }


main =
    Spa.init
        { defaultView = View.defaultView
        , extractIdentity =
            \shared ->
                case shared.currentUser of
                    Shared.SignedOut ->
                        Nothing

                    Shared.SignedIn currentUser ->
                        Just currentUser
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
            , protectPage = Route.toUrl >> Just >> Route.SignIn >> Route.toUrl
            }
        |> Browser.application
