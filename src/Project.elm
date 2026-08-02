module Project exposing (RouteParams, Msg(..), Slug, all, nav, default)

import PagesMsg exposing (PagesMsg)
import Route

import Html exposing (Attribute, Html, br, div, h3, h4, li, text, ul)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)


all : List Project
all =
    [ Project "Linqa is a bilingual whiteboard" "linqa"
    , Project "DM6 Elm" "dm6-elm"
    ]


type alias Project =
    { name : String
    , slug : Slug
    }


type alias RouteParams =
    { slug : Slug }


type Msg =
    Clicked Slug


type alias Slug =
    String


nav : RouteParams -> List (Html (PagesMsg Msg))
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


link : Slug -> Html (PagesMsg Msg)
link slug =
    case lookup slug of
        Just project ->
            Route.Project__Slug_ { slug = slug }
                |> Route.link
                    [ onClick (PagesMsg.fromMsg <| Clicked slug) ]
                    [ text project.name ]
        Nothing -> text "?"


lookup : Slug -> Maybe Project
lookup slug =
    let
        projects =
            all |> List.filter (\project -> project.slug == slug)
    in
    case projects of
        [ project ] -> Just project
        _ -> Nothing


default : Slug
default =
    case all of
        project :: _ -> project.slug
        [] -> "?"
