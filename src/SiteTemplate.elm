module SiteTemplate exposing (viewHeader, viewMain, viewFooter)

import Project
import Route
import View exposing (View)

import FeatherIcons as Icon

import Html exposing (Html, a, div, text)
import Html.Attributes exposing (href, id)



viewHeader : Project.Slug -> List (Html msg)
viewHeader selectedProject =
    [ div [ id "home" ]
        [ Route.Index |> Route.link [] [ text "dmx.berlin" ] ]
    , div [ id "nav" ]
        [ div [] [ text "" ] -- TODO: "Blog"
        , Route.Project__Slug_ { slug = selectedProject }
            |> Route.link [] [ text "Projects" ]
        ]
    ]


viewMain : View msg -> List (Html msg)
viewMain page =
    (case page.nav of
        Just nav -> [ Html.nav [] nav ]
        Nothing -> []
    )
    ++
    [ div [ id "body" ] page.body ]


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
