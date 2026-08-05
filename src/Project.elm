module Project exposing (RouteParams, Msg(..), Slug, all, viewNav, fromRoute, lookup,
    default)

import PagesMsg exposing (PagesMsg)
import Route exposing (Route(..))

import Html exposing (Html, b, div, li, text, ul)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)



all : List Project
all =
    [ Project "DM6 Elm" "dm6-elm" "The screen, redesigned for focus"
    , Project "Linqa" "linqa" "A bilingual whiteboard"
    , Project "DMX" "dmx" "Platform for knowledge management and collaboration"
    , Project "Elm Timelines" "elm-timelines" "Biographical timelines that can deal with fuzzy memory"
    ]


type alias Project =
    { name : String
    , slug : Slug
    , tagline : String
    }


type alias RouteParams =
    { slug : Slug }


type Msg =
    Clicked Slug


type alias Slug =
    String


viewNav : RouteParams -> List (Html (PagesMsg Msg))
viewNav routeParams =
    [ div [] [ text "Projects" ]
    , ul []
        (all |> List.map
            (\{slug} ->
                let
                    attr =
                        if routeParams.slug == slug then
                            [ class "selected" ]
                        else
                            []
                in
                li attr [ link slug ]
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
                    [ b [] [ text project.name ]
                    , div [ class "tagline" ] [ text project.tagline ]
                    ]
        Nothing -> text "?"


fromRoute : Route -> Maybe Slug
fromRoute route =
    case route of
        Project__Slug_ { slug } -> Just slug
        _ -> Nothing


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
