module DmxBerlin exposing (Model, view, viewFront)

import Project

import FeatherIcons as Icon
import Route
import UrlPath exposing (UrlPath)
import View exposing (View)

import Html exposing (Html, a, br, div, text)
import Html.Attributes exposing (href, id)



screenThreshold = 640


type alias Model =
    { windowWidth : Maybe Int -- not available at build time
    , selectedProject : Project.Slug
    , navMode : Bool          -- only used for small screens
    }


view : UrlPath -> Model -> View msg -> { title : String, body : List (Html msg) }
view path model page =
    let
        mainAttr =
            case path of
                segment :: _ -> [ id segment ]
                [] -> [ id "front" ]
    in
    { title = "dmx.berlin - " ++ page.title
    , body =
        [ Html.header [] (viewHeader model.selectedProject)
        , Html.main_ mainAttr
            (   viewNav page model
                ++
                [ div [ id "body" ] page.body ]
            )
        , Html.footer [] viewFooter
        ]
    }


viewHeader : Project.Slug -> List (Html msg)
viewHeader selectedProject =
    [ div [ id "home" ]
        [ Route.Index |> Route.link [] [ text "dmx.berlin" ] ]
    , div [ id "nav" ]
        [ a [ href "https://forum.dmx.berlin" ] [ text "Forum" ]
        , Route.Project__Slug_ { slug = selectedProject }
            |> Route.link [] [ text "Projects" ]
        ]
    ]


viewNav : View msg -> Model -> List (Html msg)
viewNav page model =
    case page.nav of
        Just nav ->
            if not (isSmallScreen model) || model.navMode then
                [ Html.nav [] nav ]
            else
                []
        Nothing -> []


isSmallScreen : Model -> Bool
isSmallScreen model =
    case model.windowWidth of
        Just width ->
            width < screenThreshold
        Nothing ->
            False -- prerender both, nav and body


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
