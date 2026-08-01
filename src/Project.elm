module Project exposing (all, nav)

import Route

import Html exposing (Html, br, div, li, text, ul)


all : List Project
all =
    [ Project "Linqa" "linqa"
    , Project "DM6 Elm" "dm6-elm"
    ]


type alias Project =
    { name : String
    , slug : String
    }


nav : List (Html msg)
nav =
    [ ul []
        (all |>
            List.map (\{name, slug} -> li [] [ link slug ])
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
