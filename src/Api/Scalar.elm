-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.Scalar exposing (Codecs, Date(..), Id(..), Long(..), Time(..), defaultCodecs, defineCodecs, unwrapCodecs, unwrapEncoder)

import Graphql.Codec exposing (Codec)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type Date
    = Date String


type Id
    = Id String


type Long
    = Long String


type Time
    = Time String


defineCodecs :
    { codecDate : Codec valueDate
    , codecId : Codec valueId
    , codecLong : Codec valueLong
    , codecTime : Codec valueTime
    }
    -> Codecs valueDate valueId valueLong valueTime
defineCodecs definitions =
    Codecs definitions


unwrapCodecs :
    Codecs valueDate valueId valueLong valueTime
    ->
        { codecDate : Codec valueDate
        , codecId : Codec valueId
        , codecLong : Codec valueLong
        , codecTime : Codec valueTime
        }
unwrapCodecs (Codecs unwrappedCodecs) =
    unwrappedCodecs


unwrapEncoder :
    (RawCodecs valueDate valueId valueLong valueTime -> Codec getterValue)
    -> Codecs valueDate valueId valueLong valueTime
    -> getterValue
    -> Graphql.Internal.Encode.Value
unwrapEncoder getter (Codecs unwrappedCodecs) =
    (unwrappedCodecs |> getter |> .encoder) >> Graphql.Internal.Encode.fromJson


type Codecs valueDate valueId valueLong valueTime
    = Codecs (RawCodecs valueDate valueId valueLong valueTime)


type alias RawCodecs valueDate valueId valueLong valueTime =
    { codecDate : Codec valueDate
    , codecId : Codec valueId
    , codecLong : Codec valueLong
    , codecTime : Codec valueTime
    }


defaultCodecs : RawCodecs Date Id Long Time
defaultCodecs =
    { codecDate =
        { encoder = \(Date raw) -> Encode.string raw
        , decoder = Object.scalarDecoder |> Decode.map Date
        }
    , codecId =
        { encoder = \(Id raw) -> Encode.string raw
        , decoder = Object.scalarDecoder |> Decode.map Id
        }
    , codecLong =
        { encoder = \(Long raw) -> Encode.string raw
        , decoder = Object.scalarDecoder |> Decode.map Long
        }
    , codecTime =
        { encoder = \(Time raw) -> Encode.string raw
        , decoder = Object.scalarDecoder |> Decode.map Time
        }
    }