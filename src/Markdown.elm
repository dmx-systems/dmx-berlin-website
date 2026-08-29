module Markdown exposing (Markdown, view)

import Markdown.Html
import Markdown.Parser
import Markdown.Renderer

import Html exposing (Html, div, text)
import Html.Attributes as Attributes exposing (class, style)



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
            [ publicationTag
            , imageTag
            , videoTag
            , newWindowTag
            ]
    }


publicationTag : Markdown.Html.Renderer (List (Html msg) -> Html msg)
publicationTag =
    Markdown.Html.tag "publication"
        (\authors title coverUrl pdfUrl pageCount children ->
            Html.div
                [ class "publication"
                , style "display" "flex"
                , style "gap" "4em"
                ]
                [ div []
                    [ viewImg coverUrl (Just "180px") Nothing [] ]
                , div []
                    (   [ div [] [ text authors ]
                        , div
                            [ style "font-size" "1.3em"
                            , style "font-weight" "bold"
                            ]
                            [ text title ]
                        ]
                        ++ children
                        ++
                        [ div
                            [ style "display" "flex"
                            , style "align-items" "center"
                            , style "gap" "0.7em"
                            , style "line-height" "1"
                            ]
                            [ Html.a
                                [ Attributes.href pdfUrl ]
                                [ viewImg "/publications/pdf.gif" Nothing Nothing [] ]
                            , text <| "Full article (PDF, " ++ pageCount ++ " pages)"
                            ]
                        ]
                    )
                ]
        )
        |> Markdown.Html.withAttribute "authors"
        |> Markdown.Html.withAttribute "title"
        |> Markdown.Html.withAttribute "cover-url"
        |> Markdown.Html.withAttribute "pdf-url"
        |> Markdown.Html.withAttribute "page-count"


imageTag : Markdown.Html.Renderer (List (Html msg) -> Html msg)
imageTag =
    Markdown.Html.tag "image"
        viewImg
        |> Markdown.Html.withAttribute "src"
        |> Markdown.Html.withOptionalAttribute "width"
        |> Markdown.Html.withOptionalAttribute "float"


viewImg : String -> Maybe String -> Maybe String -> List (Html msg) -> Html msg
viewImg src maybeWidth maybeFloat children =
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
                            , Attributes.style "margin" "0.5em 2em 1em 0"
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
