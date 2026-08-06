module DmxBerlin exposing (Model, Msg(..), view, viewFront)

import Project

import FeatherIcons as Icon
import Route
import UrlPath exposing (UrlPath)
import View exposing (View)

import Html exposing (Html, a, br, div, text)
import Html.Attributes exposing (class, href, id)
import Html.Events exposing (onClick)



screenThreshold = 640 -- width


type alias Model =
    { windowWidth : Maybe Int -- not available at pre-render time
    , selectedProject : Project.Slug
    , navMode : Bool          -- only used for small screens
    }


type Msg
    = EnterNavMode
    | SelectProject Project.Slug


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
    { title = "A Cognitive Home"
    , body =
        [ div []
            [ div [ id "title" ] [ text "A Cognitive Home" ]
            , div [ id "subtitle" ] [ text "The screen, redesigned for focus" ]
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
    [ div [ id "home" ]
        [ Route.link
            []
            [ text "dmx.berlin" ]
            Route.Index
        ]
    , div [ id "nav" ]
        [ a [ href "https://forum.dmx.berlin" ] [ text "Forum" ]
        , Route.link
            [ onClick <| toMsg EnterNavMode ]
            [ text "Projects" ]
            (Route.Project__Slug_ { slug = model.selectedProject })
        ]
    ]


viewMain : View msg -> Model -> List (Html msg)
viewMain page model =
    let
        isBigScreen = not (isSmallScreen model)
        (hasNav, viewNav) =
            case page.nav of
                Just nav ->
                    if isBigScreen || model.navMode then
                        (True, [ Html.nav [] nav ])
                    else
                        (True, [])
                Nothing ->
                    (False, [])
        viewBody =
            if isBigScreen || not hasNav || not model.navMode then
                [ div [ id "body" ] page.body ]
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
