module Route.Project.Slug__ exposing (ActionData, Data, Model, Msg, route)

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
    Maybe Markdown


type alias Markdown =
    String


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


-- pages : BackendTask FatalError (List RouteParams)
-- pages =
--     Project.all
--         |> List.map (\{slug} -> RouteParams (Just slug))
--         |> (::) (RouteParams Nothing)
--         |> BackendTask.succeed


-- TODO: drop
pages : BackendTask FatalError (List RouteParams)
pages =
    [ RouteParams <| Just "dm6-elm"
    , RouteParams <| Just "linqa"
    , RouteParams Nothing
    ]
    |> BackendTask.succeed


data : RouteParams -> BackendTask FatalError Data
data routeParams =
    case routeParams.slug of
        Just slug ->
            File.rawFile ("content/projects/" ++ slug ++ ".md")
                |> BackendTask.map Just
                |> BackendTask.allowFatal
        Nothing ->
            BackendTask.succeed Nothing


head : App Data ActionData RouteParams -> List Head.Tag
head app =
    []


view :
    App Data ActionData RouteParams -> Shared.Model -> Model
    -> View (PagesMsg Msg)
view app shared model =
    { title =
        case app.routeParams.slug of
            Just slug ->
                Project.lookup slug
                    |> Maybe.map .name
                    |> Maybe.withDefault "?" -- error (lookup failed)
            Nothing -> "Projects"
    , body =
        app.data
            |> Maybe.map viewMarkdown
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
