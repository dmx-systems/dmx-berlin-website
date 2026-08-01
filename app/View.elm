module View exposing (View, map)

{-| View module for elm-pages, utilizing plain "Html" Elm API.

@docs View, map

-}

import Html exposing (Html)


{-| -}
type alias View msg =
    { title : String
    , body : List (Html msg)
    , nav : Maybe (List (Html msg))
    }


{-| -}
map : (msg1 -> msg2) -> View msg1 -> View msg2
map fn doc =
    { title = doc.title
    , body = doc.body
        |> List.map (Html.map fn)
    , nav = doc.nav
        |> Maybe.map (List.map (Html.map fn))
    }
