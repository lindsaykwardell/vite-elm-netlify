module Api exposing (request)

import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet exposing (SelectionSet)
import RemoteData exposing (RemoteData)


request : SelectionSet a RootQuery -> Maybe String -> (RemoteData (Graphql.Http.Error a) a -> msg) -> Cmd msg
request query token msg =
    query
        |> Graphql.Http.queryRequest "/api"
        |> (\r ->
                case token of
                    Just t ->
                        Graphql.Http.withHeader "Authorization" ("Bearer " ++ t) r

                    Nothing ->
                        r
           )
        |> Graphql.Http.send (RemoteData.fromResult >> msg)
