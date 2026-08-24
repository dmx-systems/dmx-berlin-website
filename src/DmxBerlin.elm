module DmxBerlin exposing (Model, Msg(..), Width, view, viewFront, viewAbout)

import Project

import FeatherIcons as Icon
import Route
import UrlPath exposing (UrlPath)
import View exposing (View)

import Html exposing (Html, a, button, div, h1, li, menu, text)
import Html.Attributes exposing (class, href, id)
import Html.Events exposing (onClick)



thresholdWidth : Width
thresholdWidth = 640


type alias Model =
    { isMenuOpen : Bool
    , selectedProject : Project.Slug
    , windowWidth : Maybe Width -- not available at pre-render time
    }


type Msg
    = MenuClicked
    | ProjectSelected Project.Slug
    | WindowResized Width


type alias Width =
    Int


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


viewHeader : Model -> (Msg -> msg) -> List (Html msg)
viewHeader model toMsg =
    let
        slug =
            if isSmallScreen model then
                Nothing
            else
                Just model.selectedProject
    in
    [ div
        [ id "home" ]
        [ Route.link
            []
            [ text "dmx.berlin" ]
            Route.Index
        ]
    , div
        [ id "nav" ]
        [ Route.link
            []
            [ text "Projects" ]
            (Route.Project__Slug__ { slug = slug })
        , a [ href "https://forum.dmx.berlin" ] [ text "DMX Forum" ]
        , Route.link
            []
            [ text "About" ]
            (Route.About)
        , button
            [ onClick <| toMsg MenuClicked ]
            [ Icon.menu |> Icon.withSize 1 |> Icon.withSizeUnit "em"
                |> Icon.toHtml []
            ]
        ]
    ]
    ++ viewMenu model


viewMenu : Model -> List (Html msg)
viewMenu model =
    if model.isMenuOpen then
        [ menu
            []
            [ li [] [ text "Item 1" ]
            , li [] [ text "Item 2" ]
            , li [] [ text "Item 3" ]
            ]
        ]
    else
        []


viewMain : View msg -> Model -> List (Html msg)
viewMain page model =
    let
        isBigScreen = not (isSmallScreen model)
        isNavOnlyRoute = page.article == Nothing
        viewNav =
            case page.nav of
                Just nav ->
                    if isBigScreen || isNavOnlyRoute then
                        [ Html.nav [] nav ]
                    else
                        []
                Nothing ->
                    []
        viewArticle =
            if not isNavOnlyRoute then
                [ Html.article []
                    (page.article
                        |> Maybe.withDefault [ text "❌ article missing" ]
                    )
                ]
            else
                []
    in
    viewNav ++ viewArticle


isSmallScreen : Model -> Bool
isSmallScreen model =
    case model.windowWidth of
        Just width ->
            width < thresholdWidth
        Nothing ->
            False -- pre-render both, nav and article


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


-- Front page

viewFront : View msg
viewFront =
    { title = "The screen, redesigned for focus"
    , nav = Nothing
    , article =
        Just
            [ div []
                [ div
                    [ id "title" ]
                    [ text "A Cognitive Home" ]
                , div
                    [ id "subtitle" ]
                    [ text "The screen, redesigned for focus" ]
                ]
            , div
                [ id "person" ]
                [ div [] [ text "Jörg Richter" ]
                , div [] [ text "Software Developer, Berlin" ]
                ]
            ]
    }


-- About page

viewAbout : View msg
viewAbout =
    { title = "About"
    , nav = Nothing
    , article =
        Just
            [ h1 [] [ text "About" ]
            , div [] [ text "This website ..." ]
            ]
    }
