module Shared exposing (Data, Model, Msg(..), template)

import Project
import SiteTemplate

import BackendTask exposing (BackendTask)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import UrlPath exposing (UrlPath)
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import View exposing (View)

import Html exposing (Attribute, Html)
import Html.Attributes exposing (id)



template : SharedTemplate Msg Model Data msg
template =
    { init = init
    , update = update
    , view = view
    , data = data
    , subscriptions = subscriptions
    , onPageChange = Nothing
    }


type Msg
    = SelectProject Project.Slug


type alias Data =
    ()


type alias Model =
    { selectedProject : Project.Slug
    }


type alias PagePath =
    { path :
        { path : UrlPath
        , query : Maybe String
        , fragment : Maybe String
        }
    , metadata : Maybe Route
    , pageUrl : Maybe PageUrl
    }


init : Pages.Flags.Flags -> Maybe PagePath -> ( Model, Effect Msg )
init flags maybePagePath =
    ( { selectedProject = initProject maybePagePath }
    , Effect.none
    )


initProject : Maybe PagePath -> Project.Slug
initProject maybePagePath =
    maybePagePath
        |> Maybe.andThen .metadata
        |> Maybe.andThen Project.fromRoute
        |> Maybe.withDefault Project.default


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        SelectProject slug ->
            ( { model | selectedProject = slug }, Effect.none )


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
view sharedData {path} model toMsg page =
    { title = "dmx.berlin - " ++ page.title
    , body =
        [ Html.header [] (SiteTemplate.viewHeader model.selectedProject)
        , Html.main_ (mainAttr path) (SiteTemplate.viewMain page)
        , Html.footer [] SiteTemplate.viewFooter
        ]
    }


mainAttr : UrlPath -> List (Attribute msg)
mainAttr path =
    case path of
        page :: _ -> [ id page ]
        [] -> [ id "front" ]
