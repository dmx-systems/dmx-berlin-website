module Route.Index exposing (ActionData, Data, Model, Msg, route)

import DmxBerlin

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import RouteBuilder exposing (App, StatelessRoute)
import Shared
import View exposing (View)



type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    ()


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
    BackendTask.succeed ()


head : App Data ActionData RouteParams -> List Head.Tag
head app =
    []


view : App Data ActionData RouteParams -> Shared.Model -> View msg
view app sharedModel =
    DmxBerlin.viewFront
