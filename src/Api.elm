module Api exposing (Query, mutate, query)

import Graphql.Http
import Graphql.Operation exposing (RootMutation, RootQuery)
import Graphql.SelectionSet exposing (SelectionSet)
import RemoteData exposing (RemoteData)


type alias Query a =
    RemoteData (Graphql.Http.Error a) a


query : SelectionSet a RootQuery -> Maybe String -> (Query a -> msg) -> Cmd msg
query q token msg =
    q
        |> Graphql.Http.queryRequest "/api"
        |> Graphql.Http.withHeader "Authorization" ("Bearer " ++ (token |> Maybe.withDefault ""))
        |> Graphql.Http.send (RemoteData.fromResult >> msg)


mutate : SelectionSet a RootMutation -> Maybe String -> (Query a -> msg) -> Cmd msg
mutate q token msg =
    q
        |> Graphql.Http.mutationRequest "/api"
        |> Graphql.Http.withHeader "Authorization" ("Bearer " ++ (token |> Maybe.withDefault ""))
        |> Graphql.Http.send (RemoteData.fromResult >> msg)
