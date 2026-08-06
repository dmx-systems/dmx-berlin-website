module Route.Project.Slug_ exposing (ActionData, Data, Model, Msg, route)

import DmxBerlin
import Project exposing (RouteParams)

import BackendTask exposing (BackendTask)
import BackendTask.File as File
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Head
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatefulRoute)
import Shared
import UrlPath exposing (UrlPath)
import View exposing (View)

import Markdown.Parser as Parser
import Markdown.Renderer as Renderer

import Html exposing (Html, text)



type alias Model =
    {}


type alias Msg =
    Project.Msg


type alias Data =
    Project.Slug


type alias ActionData =
    ()


route : StatefulRoute RouteParams Data ActionData Model Msg
route =
    RouteBuilder.preRender
        { head = head
        , data = data
        , pages = pages
        }
        |> RouteBuilder.buildWithSharedState
            { view = view
            , init = init
            , update = update
            , subscriptions = subscriptions
            }


pages : BackendTask FatalError (List RouteParams)
pages =
    BackendTask.succeed
        (Project.all
            |> List.map (\{slug} -> { slug = slug })
        )


data : RouteParams -> BackendTask FatalError Data
data routeParams =
    let
        file = "content/projects/" ++ routeParams.slug ++ ".md"
    in
    File.rawFile file
        |> BackendTask.allowFatal


head : App Data ActionData RouteParams -> List Head.Tag
head app =
    []


view :
    App Data ActionData RouteParams -> Shared.Model -> Model
    -> View (PagesMsg Msg)
view app shared model =
    { title =
        Project.lookup app.routeParams.slug
            |> Maybe.map .name
            |> Maybe.withDefault "?"
    , body =
        app.data
            |> viewMarkdown
    , nav =
        Just (Project.viewNav app.routeParams)
    }


init : App Data ActionData RouteParams -> Shared.Model -> ( Model, Effect Msg )
init app shared =
    ( {}, Effect.none )


update :
    App Data ActionData RouteParams -> Shared.Model -> Msg -> Model
    -> ( Model, Effect Msg, Maybe Shared.Msg )
update app shared msg model =
    case msg of
        Project.Clicked slug ->
            ( model, Effect.none, Just <| DmxBerlin.SelectProject slug )


subscriptions : RouteParams -> UrlPath -> Shared.Model -> Model -> Sub Msg
subscriptions routeParams path shared model =
    Sub.none


viewMarkdown : String -> List (Html msg)
viewMarkdown source =
    case Parser.parse source of
        Ok blocks ->
            blocks
                |> Renderer.render Renderer.defaultHtmlRenderer
                |> Result.withDefault [ text "Markdown render error" ]
        Err _ ->
            [ text "Markdown parse error" ]
