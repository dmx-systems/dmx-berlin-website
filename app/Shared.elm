port module Shared exposing (Data, Model, Msg, template)

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



-- PORTS


port onPointerdown : (() -> msg) -> Sub msg
port onResize : (DmxBerlin.Width -> msg) -> Sub msg



-- MAIN


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


type alias Msg =
    DmxBerlin.Msg


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
    ( { isMenuOpen = False
      , selectedProject = initProject maybePagePath
      , windowWidth = initWindowWidth flags
      }
    , Effect.none
    )


initWindowWidth : Flags -> Maybe DmxBerlin.Width
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
        DmxBerlin.MenuClicked ->
            ( { model | isMenuOpen = not model.isMenuOpen }
            , Effect.none
            )
        DmxBerlin.ProjectSelected slug ->
            ( { model | selectedProject = slug }
            , Effect.none
            )
        DmxBerlin.WindowResized width ->
            ( { model | windowWidth = Just width }
            , Effect.none
            )
        DmxBerlin.CancelUI ->
            ( { model | isMenuOpen = False }
            , Effect.none
            )
        DmxBerlin.NoOp ->
            ( model, Effect.none )


subscriptions : UrlPath -> Model -> Sub Msg
subscriptions _ _ =
    Sub.batch
        [ onResize DmxBerlin.WindowResized
        , onPointerdown (\() -> DmxBerlin.CancelUI)
        ]


data : BackendTask FatalError Data
data =
    BackendTask.succeed ()


view :
    Data -> { path : UrlPath, route : Maybe Route }
    -> Model -> (Msg -> msg) -> View msg
    -> { title : String, body : List (Html msg) }
view _ {path} model toMsg page =
    DmxBerlin.view path model toMsg page
