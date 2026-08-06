module Shared exposing (Data, Model, Msg, template)

import Project
import DmxBerlin

import BackendTask exposing (BackendTask)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Pages.Flags exposing (Flags(..))
import Pages.PageUrl exposing (PageUrl)
import UrlPath exposing (UrlPath)
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import View exposing (View)

import Html exposing (Html)
import Json.Decode as D



template : SharedTemplate Msg Model Data msg
template =
    { init = init
    , update = update
    , view = view
    , data = data
    , subscriptions = subscriptions
    , onPageChange = Nothing
    }


type alias Model =
    DmxBerlin.Model


type alias Msg
    = DmxBerlin.Msg


type alias Data =
    ()


type alias PagePath =
    { path :
        { path : UrlPath
        , query : Maybe String
        , fragment : Maybe String
        }
    , metadata : Maybe Route
    , pageUrl : Maybe PageUrl
    }


init : Flags -> Maybe PagePath -> ( Model, Effect Msg )
init flags maybePagePath =
    (   { windowWidth = initWindowWidth flags
        , selectedProject = initProject maybePagePath
        , navMode = False
        }
    , Effect.none
    )


initWindowWidth : Flags -> Maybe Int
initWindowWidth flags =
    case flags of
        BrowserFlags value ->
            case value |> D.decodeValue D.int of
                Ok width -> Just width
                Err e -> Nothing
        PreRenderFlags -> Nothing


initProject : Maybe PagePath -> Project.Slug
initProject maybePagePath =
    maybePagePath
        |> Maybe.andThen .metadata
        |> Maybe.andThen Project.fromRoute
        |> Maybe.withDefault Project.default


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        DmxBerlin.EnterNavMode ->
            ( { model | navMode = True }
            , Effect.none
            )
        DmxBerlin.SelectProject slug ->
            ( { model | selectedProject = slug
                      , navMode = False
              }
            , Effect.none
            )


subscriptions : UrlPath -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none


data : BackendTask FatalError Data
data =
    BackendTask.succeed ()


view :
    Data -> { path : UrlPath, route : Maybe Route }
    -> Model -> (Msg -> msg) -> View msg
    -> { title : String, body : List (Html msg) }
view _ {path} model toMsg page =
    DmxBerlin.view path model toMsg page
