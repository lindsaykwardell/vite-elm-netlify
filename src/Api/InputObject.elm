-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Api.InputObject exposing (..)

import Api.Interface
import Api.Object
import Api.Scalar
import Api.ScalarCodecs
import Api.Union
import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode


buildPartialUpdateTodoInput :
    (PartialUpdateTodoInputOptionalFields -> PartialUpdateTodoInputOptionalFields)
    -> PartialUpdateTodoInput
buildPartialUpdateTodoInput fillOptionals____ =
    let
        optionals____ =
            fillOptionals____
                { title = Absent, completed = Absent }
    in
    { title = optionals____.title, completed = optionals____.completed }


type alias PartialUpdateTodoInputOptionalFields =
    { title : OptionalArgument String
    , completed : OptionalArgument Bool
    }


{-| Type for the PartialUpdateTodoInput input object.
-}
type alias PartialUpdateTodoInput =
    { title : OptionalArgument String
    , completed : OptionalArgument Bool
    }


{-| Encode a PartialUpdateTodoInput into a value that can be used as an argument.
-}
encodePartialUpdateTodoInput : PartialUpdateTodoInput -> Value
encodePartialUpdateTodoInput input____ =
    Encode.maybeObject
        [ ( "title", Encode.string |> Encode.optional input____.title ), ( "completed", Encode.bool |> Encode.optional input____.completed ) ]


buildTodoInput :
    TodoInputRequiredFields
    -> (TodoInputOptionalFields -> TodoInputOptionalFields)
    -> TodoInput
buildTodoInput required____ fillOptionals____ =
    let
        optionals____ =
            fillOptionals____
                { completed = Absent }
    in
    { title = required____.title, completed = optionals____.completed }


type alias TodoInputRequiredFields =
    { title : String }


type alias TodoInputOptionalFields =
    { completed : OptionalArgument Bool }


{-| Type for the TodoInput input object.
-}
type alias TodoInput =
    { title : String
    , completed : OptionalArgument Bool
    }


{-| Encode a TodoInput into a value that can be used as an argument.
-}
encodeTodoInput : TodoInput -> Value
encodeTodoInput input____ =
    Encode.maybeObject
        [ ( "title", Encode.string input____.title |> Just ), ( "completed", Encode.bool |> Encode.optional input____.completed ) ]