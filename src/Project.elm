module Project exposing (RouteParams, Msg(..), Slug, all, viewNav, fromRoute,
    lookup, default)

import PagesMsg exposing (PagesMsg)
import Route exposing (Route(..))

import Html exposing (Html, b, div, li, text, ul)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)



all : List Project
all =
    [ Project "DM6 Elm" "dm6-elm" "An user interface to support focus"
    , Project "Linqa" "linqa" "A bilingual whiteboard"
    , Project "DMX" "dmx" "Platform for knowledge management and collaboration"
    , Project "Elm Timelines" "elm-timelines"
        "Biographical timelines that can deal with fuzzy memory"
    ]


type alias Project =
    { name : String
    , slug : Slug
    , tagline : String
    }


type alias RouteParams =
    { slug : Maybe Slug }


type Msg =
    Clicked Slug


type alias Slug =
    String


viewNav : RouteParams -> List (Html (PagesMsg Msg))
viewNav routeParams =
    [ div [] [ text "Projects" ]
    , ul []
        (all
            |> List.map
                (\{slug} ->
                    let
                        attr =
                            case routeParams.slug of
                                Just slug_ ->
                                    if slug_ == slug then
                                        [ class "selected" ]
                                    else
                                        []
                                Nothing ->
                                    []
                        enabled = -- TODO: drop
                            [ "dm6-elm", "linqa" ] |> List.member slug
                        linkFunc = -- TODO: drop
                            if enabled then link else disabledLink
                    in
                    li attr [ linkFunc slug ]
                )
        )
    ]


link : Slug -> Html (PagesMsg Msg)
link slug =
    case lookup slug of
        Just project ->
            Route.Project__Slug__ { slug = Just slug }
                |> Route.link
                    [ onClick (PagesMsg.fromMsg <| Clicked slug) ]
                    [ b [] [ text project.name ]
                    , div [ class "tagline" ] [ text project.tagline ]
                    ]
        Nothing -> text "?" -- error (lookup failed)


-- TODO: drop
disabledLink : Slug -> Html (PagesMsg Msg)
disabledLink slug =
    case lookup slug of
        Just project ->
            div
                []
                [ b [] [ text project.name ]
                , div [ class "tagline" ] [ text project.tagline ]
                ]
        Nothing -> text "?" -- error (lookup failed)


fromRoute : Route -> Maybe Slug
fromRoute route =
    case route of
        Project__Slug__ { slug } -> slug
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
        [] -> "?" -- error (no projects defined)
