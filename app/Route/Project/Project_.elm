module Route.Project.Project_ exposing (ActionData, Data, Model, Msg, route)

import Shared
import View exposing (View)

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import PagesMsg exposing (PagesMsg)
import RouteBuilder exposing (App, StatelessRoute)

import Html exposing (Html, br, div, text)
import Html.Attributes exposing (id)



type alias Model =
    {}


type alias Msg =
    ()


type alias RouteParams =
    { project : String }


type alias Data =
    ()


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
        [ { project = "linqa" }
        ]


data : RouteParams -> BackendTask FatalError Data
data routeParams =
    BackendTask.succeed ()


head : App Data ActionData RouteParams -> List Head.Tag
head app =
    []


view : App Data ActionData RouteParams -> Shared.Model -> View (PagesMsg Msg)
view app sharedModel =
    { title = "Projects - "
    , body =
        [ div [] [ text <| "project: " ++ app.routeParams.project ]
        , div [] [ text <| "shared model: " ++ if sharedModel.showMenu then "true" else "false" ]
        ]
    , name = "project"
    , nav = Just nav
    }


nav : List (Html msg)
nav =
    [ text "project nav" ]
