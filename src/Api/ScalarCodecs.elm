-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.ScalarCodecs exposing (..)

import Api.Scalar exposing (defaultCodecs)
import Json.Decode as Decode exposing (Decoder)


type alias Date =
    Api.Scalar.Date


type alias Id =
    Api.Scalar.Id


type alias Long =
    Api.Scalar.Long


type alias Time =
    Api.Scalar.Time


codecs : Api.Scalar.Codecs Date Id Long Time
codecs =
    Api.Scalar.defineCodecs
        { codecDate = defaultCodecs.codecDate
        , codecId = defaultCodecs.codecId
        , codecLong = defaultCodecs.codecLong
        , codecTime = defaultCodecs.codecTime
        }
