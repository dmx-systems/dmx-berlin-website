module Route.Index exposing (ActionData, Data, Model, Msg, route)

import DmxBerlin

import BackendTask exposing (BackendTask)
import FatalError exposing (FatalError)
import Head
import Head.Seo as Seo
import Pages.Url
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
    Seo.summary
        { title = "dmx.berlin – A Cognitive Home"
        , image =
            { url = [ "previews", "index.png" ] |> Pages.Url.fromPath
            , alt = "index image alt TODO"
            , dimensions = Nothing
            , mimeType = Nothing
            }
        , description = "index description TODO"
        , siteName = "index siteName TODO"
        , locale = Nothing
        , canonicalUrlOverride = Nothing
        }
        |> Seo.website


view : App Data ActionData RouteParams -> Shared.Model -> View msg
view app sharedModel =
    DmxBerlin.viewFront
