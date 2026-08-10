module DmxBerlin exposing (Model, Msg(..), view, viewFront)

import Project

import FeatherIcons as Icon
import Route
import UrlPath exposing (UrlPath)
import View exposing (View)

import Html exposing (Html, a, br, div, text)
import Html.Attributes exposing (class, href, id)



screenThreshold = 640 -- width


type alias Model =
    { selectedProject : Project.Slug
    , windowWidth : Maybe Int -- not available at pre-render time
    }


type Msg
    = SelectProject Project.Slug
    | WindowResized Int -- width


view :
    UrlPath -> Model -> (Msg -> msg) -> View msg
    -> { title : String, body : List (Html msg) }
view path model toMsg page =
    let
        mainId =
            case path of
                segment :: _ -> segment
                [] -> "front"
        mainClass =
            if isSmallScreen model then
                [ class "small-screen" ]
            else
                []
    in
    { title = "dmx.berlin - " ++ page.title
    , body =
        [ Html.header [] (viewHeader model toMsg)
        , Html.main_
            ([ id mainId ] ++ mainClass)
            (viewMain page model)
        , Html.footer [] viewFooter
        ]
    }


viewFront : View msg
viewFront =
    { title = "The screen, redesigned for focus"
    , body =
        Just
            [ div []
                [ div
                    [ id "title" ]
                    [ text "A Cognitive Home" ]
                , div
                    [ id "subtitle" ]
                    [ text "The screen, redesigned for focus" ]
                ]
            , div [ id "profile" ]
                [ text "Jörg Richter", br [] []
                , text "Software Developer, Berlin"
                ]
            ]
    , nav = Nothing
    }


viewHeader : Model -> (Msg -> msg) -> List (Html msg)
viewHeader model toMsg =
    let
        slug =
            if isSmallScreen model then
                Nothing
            else
                Just model.selectedProject
    in
    [ div [ id "home" ]
        [ Route.link
            []
            [ text "dmx.berlin" ]
            Route.Index
        ]
    , div [ id "nav" ]
        [ a [ href "https://forum.dmx.berlin" ] [ text "Forum" ]
        , Route.link
            []
            [ text "Projects" ]
            (Route.Project__Slug__ { slug = slug })
        ]
    ]


viewMain : View msg -> Model -> List (Html msg)
viewMain page model =
    let
        isBigScreen = not (isSmallScreen model)
        isNavOnlyRoute = page.body == Nothing
        viewNav =
            case page.nav of
                Just nav ->
                    if isBigScreen || isNavOnlyRoute then
                        [ Html.nav [] nav ]
                    else
                        []
                Nothing ->
                    []
        viewBody =
            if not isNavOnlyRoute then
                [ div
                    [ id "body" ]
                    (page.body
                        |> Maybe.withDefault [ text "?" ] -- error (body missing)
                    )
                ]
            else
                []
    in
    viewNav ++ viewBody


isSmallScreen : Model -> Bool
isSmallScreen model =
    case model.windowWidth of
        Just width ->
            width < screenThreshold
        Nothing ->
            False -- pre-render both, nav and body


viewFooter : List (Html msg)
viewFooter =
    [ div [ id "icons" ]
        [ a [ href "https://github.com/jri" ]
            [ Icon.github |> Icon.toHtml [] ]
        , a [ href "https://www.linkedin.com/in/jörg-richter-0a829123b/" ]
            [ Icon.linkedin |> Icon.toHtml [] ]
        , a [ href "mailto:jri@dmx.berlin" ]
            [ Icon.mail |> Icon.toHtml [] ]
        ]
    ]
