module DmxBerlin exposing (Model, Msg(..), Width, view, viewFront, viewAbout)

import Project

import FeatherIcons as Icon

import Route exposing (Route)
import UrlPath exposing (UrlPath)
import View exposing (View)

import Html exposing (Attribute, Html, a, button, div, h1, li, nav, text)
import Html.Attributes exposing (class, href, id)
import Html.Events exposing (onClick, stopPropagationOn)
import Json.Decode as D



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
    | CancelUI
    | NoOp


type Link
    = External String String -- text, href
    | Internal String (Model -> Route) -- text, route


links : List Link
links =
    [ Internal "Projects"
        (\model -> Route.Project__Slug__
            { slug =
                if isSmallScreen model then
                    Nothing
                else
                    Just model.selectedProject
            }
        )
    , External "DMX Forum" "https://forum.dmx.berlin"
    , Internal "About" (\_ -> Route.About)
    ]


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


-- Header

viewHeader : Model -> (Msg -> msg) -> List (Html msg)
viewHeader model toMsg =
    let
        slug =
            if isSmallScreen model then
                Nothing
            else
                Just model.selectedProject
    in
    [ Route.link
        []
        [ text "dmx.berlin" ]
        Route.Index
    , nav
        []
        ( viewNavLinks model []
            ++ viewSiteMenu model toMsg
        )
    ]


viewSiteMenu : Model -> (Msg -> msg) -> List (Html msg)
viewSiteMenu model toMsg =
    [ div
        [ id "site-menu"
        , onPointerDownStop <| toMsg NoOp
        ]
        (   [ button
                [ onClick <| toMsg MenuClicked ]
                [ Icon.menu |> Icon.withSize 1 |> Icon.withSizeUnit "em"
                    |> Icon.toHtml []
                ]
            ]
            ++ viewMenu model toMsg
        )
    ]


viewMenu : Model -> (Msg -> msg) -> List (Html msg)
viewMenu model toMsg =
    let
        attrs = [ onClick <| toMsg CancelUI ]
    in
    if model.isMenuOpen then
        [ nav
            []
            (viewNavLinks model attrs)
        ]
    else
        []


viewNavLinks : Model -> List (Attribute msg) -> List (Html msg)
viewNavLinks model attrs =
    links
        |> List.map
            (\link ->
                case link of
                    External text_ href_ ->
                        a ([ href href_] ++ attrs) [ text text_ ]
                    Internal text_ toRoute ->
                        Route.link attrs [ text text_ ] (toRoute model)
            )


-- Main

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


-- Footer

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


-- Screen

isSmallScreen : Model -> Bool
isSmallScreen model =
    case model.windowWidth of
        Just width ->
            width < thresholdWidth
        Nothing ->
            False -- pre-render both, nav and article


-- Events

onPointerDownStop : msg -> Attribute msg
onPointerDownStop msg =
  stopPropagation "pointerdown" msg


stopPropagation : String -> msg -> Attribute msg
stopPropagation eventName msg =
  stopPropagationOn eventName <| D.succeed (msg, True) -- stopPropagation=True
