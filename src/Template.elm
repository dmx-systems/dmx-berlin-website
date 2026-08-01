module Template exposing (header, footer)

import FeatherIcons as Icon

import Route

import Html exposing (Html, a, div, text)
import Html.Attributes exposing (href, id)



header : List (Html msg)
header =
    [ div [ id "logo" ]
        [ Route.Index |> Route.link [] [ text "home" ] ]
    , div [ id "nav" ]
        [ div [] [ text "" ] -- TODO: "Blog"
        , Route.Project__Slug_ { slug = "linqa" }
            |> Route.link [] [ text "Projects" ]
        ]
    ]


footer : List (Html msg)
footer =
    [ div [ id "icons" ]
        [ a [ href "https://github.com/jri" ]
            [ Icon.github |> Icon.toHtml [] ]
        , a [ href "https://www.linkedin.com/in/jörg-richter-0a829123b/" ]
            [ Icon.linkedin |> Icon.toHtml [] ]
        , a [ href "mailto:jri@dmx.berlin" ]
            [ Icon.mail |> Icon.toHtml [] ]
        ]
    ]
