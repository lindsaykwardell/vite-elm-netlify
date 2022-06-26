module Route exposing (Route(..), matchAbout, matchCounter, matchHome, matchTime, toRoute, toUrl)

import Url exposing (Url)
import Url.Builder as Builder
import Url.Parser exposing ((<?>), Parser, map, oneOf, parse, s, top)


type Route
    = Home
    | Todos
    | Time
    | About
    | NotFound Url


route : Parser (Route -> a) a
route =
    oneOf
        [ map Home top
        , map About <| s "about"
        , map Todos <| s "todos"
        , map Time <| s "time"
        ]


toRoute : Url -> Route
toRoute url =
    url
        |> parse route
        |> Maybe.withDefault (NotFound url)


toUrl : Route -> String
toUrl r =
    case r of
        Home ->
            "/"

        About ->
            "/about"

        Todos ->
            "/todos"

        Time ->
            "/time"

        NotFound url ->
            Url.toString url


matchAny : Route -> Route -> Maybe ()
matchAny any r =
    if any == r then
        Just ()

    else
        Nothing


matchHome : Route -> Maybe ()
matchHome =
    matchAny Home


matchAbout : Route -> Maybe ()
matchAbout r =
    case r of
        About ->
            Just ()

        _ ->
            Nothing


matchCounter : Route -> Maybe ()
matchCounter r =
    case r of
        Todos ->
            Just ()

        _ ->
            Nothing


matchTime : Route -> Maybe ()
matchTime =
    matchAny Time
