module Projects exposing (RouteParams, all, nav)

import Route

import Html exposing (Attribute, Html, br, div, h3, h4, li, text, ul)
import Html.Attributes exposing (class)


all : List Project
all =
    [ Project "Linqa is a bilingual whiteboard" "linqa"
    , Project "DM6 Elm" "dm6-elm"
    ]


type alias Project =
    { name : String
    , slug : String
    }


type alias RouteParams =
    { slug : String }


nav : RouteParams -> List (Html msg)
nav routeParams =
    [ div [] [ text "Projects" ]
    , ul []
        (all |> List.map
            (\{slug} ->
                let
                    attrs =
                        if routeParams.slug == slug then
                            [ class "selected" ]
                        else
                            []
                in
                li attrs [ link slug ]
            )
        )
    ]


link : String -> Html msg
link slug =
    case lookup slug of
        Just project ->
            Route.Project__Slug_ { slug = slug }
                |> Route.link [] [ text project.name ]
        Nothing -> text "?"


lookup : String -> Maybe Project
lookup slug =
    let
        projects =
            all |> List.filter (\project -> project.slug == slug)
    in
    case projects of
        [ project ] -> Just project
        _ -> Nothing
