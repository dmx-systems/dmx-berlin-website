module Route.Index exposing (ActionData, Data, Model, Msg, route)

import Shared
import View exposing (View)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)

import Html



type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    {}


type alias Data =
    ()


type alias ActionData =
    {}


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


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app shared =
    { title = "dmx.berlin"
    , body =
        [ Html.div [] [ Html.text "A Cognitive Home" ]
        , Html.div [] [ Html.text "The screen, redesigned for focus" ]
        , Html.div [] [ Html.text "contact@dmx.berlin" ]
        ]
    }
