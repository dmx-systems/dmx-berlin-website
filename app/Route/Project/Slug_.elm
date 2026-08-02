module Route.Project.Slug_ exposing (ActionData, Data, Model, Msg, route)

import Projects exposing (RouteParams)

import BackendTask exposing (BackendTask)
import BackendTask.File as File
import FatalError exposing (FatalError)
import Head
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import View exposing (View)

import Markdown.Parser as Parser
import Markdown.Renderer as Renderer

import Html exposing (Html, br, div, h2, li, text, ul)
import Html.Attributes exposing (id)



type alias Model =
    {}


type alias Msg =
    ()


type alias Data =
    String


type alias ActionData =
    ()


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.preRender
        { head = head
        , data = data
        , pages = pages
        }
        |> RouteBuilder.buildNoState { view = view }


pages : BackendTask FatalError (List RouteParams)
pages =
    BackendTask.succeed
        (Projects.all
            |> List.map (\{slug} -> { slug = slug })
        )


data : RouteParams -> BackendTask FatalError Data
data routeParams =
    let
        file = "content/" ++ routeParams.slug ++ ".md"
    in
    File.rawFile file
        |> BackendTask.allowFatal


head : App Data ActionData RouteParams -> List Head.Tag
head app =
    []


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app sharedModel =
    { title = "Projects - "
    , body = app.data |> markdown
    , nav = Just (Projects.nav app.routeParams)
    }


markdown : String -> List (Html msg)
markdown source =
    case Parser.parse source of
        Ok blocks ->
            blocks
                |> Renderer.render Renderer.defaultHtmlRenderer
                |> Result.withDefault [ text "Markdown render error" ]
        Err _ ->
            [ text "Markdown parse error" ]
