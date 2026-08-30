module Markdown exposing (Markdown, view)

import DmxBerlin

import Markdown.Html
import Markdown.Parser
import Markdown.Renderer

import Html exposing (Html, div, text)
import Html.Attributes as Attributes exposing (class, style)



type alias Markdown =
    String


view : DmxBerlin.Model -> Markdown -> List (Html msg)
view model source =
    case Markdown.Parser.parse source of
        Ok blocks ->
            blocks
                |> Markdown.Renderer.render (customRenderer model)
                |> Result.withDefault [ Html.text "❌ Markdown render error" ]
        Err _ ->
            [ Html.text "❌ Markdown parse error" ]


customRenderer : DmxBerlin.Model -> Markdown.Renderer.Renderer (Html msg)
customRenderer model =
    let
        default = Markdown.Renderer.defaultHtmlRenderer
    in
    { default | html =
        Markdown.Html.oneOf
            [ publicationTag model
            , imageTag model
            , videoTag
            , newWindowTag
            ]
    }


publicationTag : DmxBerlin.Model -> Markdown.Html.Renderer (List (Html msg) -> Html msg)
publicationTag model =
    Markdown.Html.tag "publication"
        (if DmxBerlin.isSmallScreen model then
            viewPublicationSmall model
        else
            viewPublication model
        )
        |> Markdown.Html.withAttribute "authors"
        |> Markdown.Html.withAttribute "title"
        |> Markdown.Html.withAttribute "cover-url"
        |> Markdown.Html.withAttribute "pdf-url"
        |> Markdown.Html.withAttribute "page-count"


viewPublication : DmxBerlin.Model -> String -> String -> String -> String -> String -> List (Html msg) -> Html msg
viewPublication model authors title coverUrl pdfUrl pageCount children =
    Html.div
        [ class "publication"
        , style "display" "flex"
        , style "gap" "4em"
        ]
        [ div []
            [ viewImg model coverUrl (Just "180px") Nothing [] ]
        , div []
            (   viewAuthorAndTitle authors title
                ++ children
                ++ [ viewPdfDownload pdfUrl pageCount ]
            )
        ]


viewPublicationSmall : DmxBerlin.Model -> String -> String -> String -> String -> String -> List (Html msg) -> Html msg
viewPublicationSmall model authors title coverUrl pdfUrl pageCount children =
    Html.div
        [ class "publication" ]
        (   viewAuthorAndTitle authors title
            ++ [ viewImg model coverUrl (Just "140px") (Just "left") [] ]
            ++ children
            ++ [ viewPdfDownload pdfUrl pageCount ]
        )


viewAuthorAndTitle : String -> String -> List (Html msg)
viewAuthorAndTitle authors title =
    [ div
        []
        [ text authors ]
    , div
        [ style "font-size" "1.3em"
        , style "font-weight" "bold"
        , style "margin-bottom" "1rem"
        ]
        [ text title ]
    ]


viewPdfDownload : String -> String -> Html msg
viewPdfDownload pdfUrl pageCount =
    div
        [ style "display" "flex"
        , style "align-items" "center"
        , style "gap" "0.7em"
        , style "line-height" "1"
        ]
        [ Html.a
            [ Attributes.href pdfUrl ]
            [ Html.img
                [ Attributes.src "/publications/pdf.gif" ]
                []
            ]
        , Html.text <| "Full article (PDF, " ++ pageCount ++ " pages)"
        ]


imageTag : DmxBerlin.Model -> Markdown.Html.Renderer (List (Html msg) -> Html msg)
imageTag model =
    Markdown.Html.tag "image"
        (viewImg model)
        |> Markdown.Html.withAttribute "src"
        |> Markdown.Html.withOptionalAttribute "width"
        |> Markdown.Html.withOptionalAttribute "float"


viewImg : DmxBerlin.Model -> String -> Maybe String -> Maybe String -> List (Html msg) -> Html msg
viewImg model src maybeWidth maybeFloat children =
    let
        marginRight =
            if DmxBerlin.isSmallScreen model then "1em" else "2em"
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
                            , Attributes.style "margin" <| "0.5em " ++ marginRight ++ " 1em 0"
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
