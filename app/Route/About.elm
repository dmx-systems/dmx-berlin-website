module Route.About exposing (ActionData, Data, Model, Msg, route)

import Markdown exposing (Markdown)

import BackendTask exposing (BackendTask)
import BackendTask.File as File
import FatalError exposing (FatalError)
import Head
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import View exposing (View)

import Html



type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    Markdown


type alias ActionData =
    ()


route : StatelessRoute RouteParams Data ActionData
route =
    RouteBuilder.single
        { head = head
        , data = data
        }
        |> RouteBuilder.buildNoState { view = view }


data : BackendTask FatalError Data
data =
    File.rawFile ("content/about.md")
        |> BackendTask.allowFatal


head : App Data ActionData RouteParams -> List Head.Tag
head app =
    []


view : App Data ActionData RouteParams -> Shared.Model -> View msg
view app sharedModel =
    { title = "About"
    , nav = [ Html.text "" ] |> Just
    , article =
        app.data
            |> Markdown.view sharedModel
            |> Just
    }
