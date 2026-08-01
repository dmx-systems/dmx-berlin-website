module Shared exposing (Data, Model, Msg(..), SharedMsg(..), template)

import Template

import BackendTask exposing (BackendTask)
import Effect exposing (Effect)
import FatalError exposing (FatalError)
import Pages.Flags
import Pages.PageUrl exposing (PageUrl)
import UrlPath exposing (UrlPath)
import Route exposing (Route)
import SharedTemplate exposing (SharedTemplate)
import View exposing (View)

import Html exposing (Attribute, Html, a, div, text)
import Html.Attributes exposing (attribute, class, href, id)
import Html.Events



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
    = SharedMsg SharedMsg
    | MenuClicked


type alias Data =
    ()


type SharedMsg
    = NoOp


type alias Model =
    { showMenu : Bool
    }


init :
    Pages.Flags.Flags
    ->
        Maybe
            { path :
                { path : UrlPath
                , query : Maybe String
                , fragment : Maybe String
                }
            , metadata : route
            , pageUrl : Maybe PageUrl
            }
    -> ( Model, Effect Msg )
init flags maybePagePath =
    ( { showMenu = False }
    , Effect.none
    )


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        SharedMsg globalMsg ->
            ( model, Effect.none )
        MenuClicked ->
            ( { model | showMenu = not model.showMenu }, Effect.none )


subscriptions : UrlPath -> Model -> Sub Msg
subscriptions _ _ =
    Sub.none


data : BackendTask FatalError Data
data =
    BackendTask.succeed ()


view :
    Data
    -> { path : UrlPath, route : Maybe Route }
    -> Model
    -> (Msg -> msg)
    -> View msg
    -> { body : List (Html msg), title : String }
view sharedData {path} model toMsg page =
    { body =
        [ Html.header [] Template.header
        , Html.main_ (mainAttr path)
            (   (case page.nav of
                    Just nav -> [ Html.nav [] nav ]
                    Nothing -> []
                )
                ++
                [ div [ id "body" ] page.body ]
            )
        , Html.footer [] Template.footer
        ]
    , title = page.title
    }


mainAttr : UrlPath -> List (Attribute msg)
mainAttr path =
    case path of
        page :: _ -> [ id page ]
        [] -> [ id "front" ]
