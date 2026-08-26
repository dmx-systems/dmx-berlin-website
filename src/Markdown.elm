module Markdown exposing (Markdown, view)

import Markdown.Html
import Markdown.Parser
import Markdown.Renderer

import Html exposing (Html)
import Html.Attributes as Attributes



type alias Markdown =
    String


view : String -> List (Html msg)
view source =
    case Markdown.Parser.parse source of
        Ok blocks ->
            blocks
                |> Markdown.Renderer.render customRenderer
                |> Result.withDefault [ Html.text "❌ Markdown render error" ]
        Err _ ->
            [ Html.text "❌ Markdown parse error" ]


customRenderer : Markdown.Renderer.Renderer (Html msg)
customRenderer =
    let
        default = Markdown.Renderer.defaultHtmlRenderer
    in
    { default | html =
        Markdown.Html.oneOf
            [ imageTag
            , videoTag
            , newWindowTag
            ]
    }


imageTag : Markdown.Html.Renderer (a -> Html msg)
imageTag =
    Markdown.Html.tag "image"
        (\src maybeWidth maybeFloat children ->
            let
                styleWidth =
                    case maybeWidth of
                        Just width -> [ Attributes.style "width" width ]
                        Nothing -> []
                styleFloat =
                    case maybeFloat of
                        Just float ->
                            case float of
                                "left" ->
                                    [ Attributes.style "float" float
                                    , Attributes.style "margin-right" "2em"
                                    , Attributes.style "margin-bottom" "1em"
                                    ]
                                _ -> [] -- TODO
                        Nothing -> []
            in
            Html.img
                ([ Attributes.src src ]
                    ++ styleWidth
                    ++ styleFloat
                )
                []
        )
        |> Markdown.Html.withAttribute "src"
        |> Markdown.Html.withOptionalAttribute "width"
        |> Markdown.Html.withOptionalAttribute "float"


videoTag : Markdown.Html.Renderer (List (Html msg) -> Html msg)
videoTag =
    Markdown.Html.tag "video"
        (\src children ->
            Html.video
                [ Attributes.src src
                , Attributes.controls True
                ]
                children
        )
        |> Markdown.Html.withAttribute "src"


newWindowTag : Markdown.Html.Renderer (a -> Html msg)
newWindowTag =
    Markdown.Html.tag "new-window"
        (\src text children ->
            Html.a
                [ Attributes.href src
                , Attributes.target "_blank"
                ]
                [ Html.text text ]
        )
        |> Markdown.Html.withAttribute "src"
        |> Markdown.Html.withAttribute "text"
