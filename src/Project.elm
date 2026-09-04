module Project exposing (RouteParams, Msg(..), Slug, all, viewNav, fromRoute, info, default)

import PagesMsg exposing (PagesMsg)
import Route exposing (Route(..))

import Html exposing (Html, b, div, li, text, ul)
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)



all : List Project
all =
    [ Project "dm6-elm"
        "DM6 Elm"
        "A cognitive work environment, built to support focus"
        "/dm6-elm.png"
    , Project "linqa"
        "Linqa"
        "A bilingual whiteboard for international collaboration"
        "/linqa/linqa.png"
    , Project "dmx-platform"
        "DMX Platform" "Platform for knowledge building, data modeling, and collaboration"
        "/dmx-platform/dmx-webclient.png"
    , Project "elm-timelines"
        "Elm Timelines"
        "Biographical timelines that can deal with fuzzy memory"
        "/elm-timelines/elm-timelines.png"
    ]


type alias Project =
    { slug : Slug
    , title : String
    , description : String
    , imagePath : String
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
                    in
                    li attr [ link slug ]
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
                    [ b [] [ text project.title ]
                    , div [ class "description" ] [ text project.description ]
                    ]
        Nothing -> text "?" -- error (lookup failed)


fromRoute : Route -> Maybe Slug
fromRoute route =
    case route of
        Project__Slug__ { slug } -> slug
        _ -> Nothing


info : RouteParams -> (Project -> info) -> info -> info -> info
info routeParams toInfo noSlugVal errVal =
    case routeParams.slug of
        Just slug ->
            lookup slug
                |> Maybe.map toInfo
                |> Maybe.withDefault errVal -- lookup failed
        Nothing -> noSlugVal


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
