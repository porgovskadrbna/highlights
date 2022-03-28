module Main exposing (..)

import Basics.Extra exposing (..)
import Browser
import Browser.Events exposing (onKeyDown)
import Html exposing (..)
import Html.Attributes as Attr
import Html.Events as Event
import Html.Extra as Html
import Html.Keyed as Keyed
import Http
import Json.Decode as Decode exposing (Decoder)
import List.Extra as List
import Maybe.Extra as Maybe
import Regex
import String.Extra as String


main : Program () Model Msg
main =
    Browser.element
        { init =
            \_ ->
                ( { query = ""
                  , img = Nothing
                  , failed = False
                  , posts = []
                  , filtered = []
                  }
                , fetchPosts
                )
        , update = update
        , view = view
        , subscriptions = \_ -> onKeyDown keyDecoder
        }



-- MODEL


type alias Model =
    { query : String
    , img : Maybe Int
    , failed : Bool
    , posts : List Post
    , filtered : List Post
    }


type alias Post =
    { src : String
    , text : String
    }


postDecoder : Decoder Post
postDecoder =
    Decode.map2 Post
        (Decode.field "src" Decode.string)
        (Decode.field "text" Decode.string)


keyDecoder : Decoder Msg
keyDecoder =
    flip Decode.map (Decode.field "key" Decode.string) <|
        \key ->
            case key of
                "ArrowLeft" ->
                    SwitchImage -1

                "ArrowRight" ->
                    SwitchImage 1

                "Escape" ->
                    ClosePreview

                _ ->
                    SwitchImage 0



-- UPDATE


type Msg
    = GotPosts (Result Http.Error (List Post))
    | NewQuery String
    | ImageChanged Int
    | SwitchImage Int
    | ClosePreview


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotPosts result ->
            case result of
                Ok posts ->
                    ( { model | posts = List.reverse posts, filtered = List.reverse posts }, Cmd.none )

                Err _ ->
                    ( { model | posts = [], failed = True }, Cmd.none )

        NewQuery queryStr ->
            let
                whitespace =
                    Maybe.withDefault Regex.never <|
                        Regex.fromString "[\\?\\+\\s,]+"
            in
            ( { model
                | query = queryStr
                , filtered =
                    if String.isEmpty queryStr then
                        model.posts

                    else
                        let
                            query =
                                queryStr
                                    |> String.toLower
                                    |> String.removeAccents

                            getText =
                                .text >> String.toLower >> String.removeAccents

                            initialsFilter =
                                case String.toList query of
                                    [ p, q ] ->
                                        let
                                            initials =
                                                List.map String.fromList <|
                                                    [ [ p, q ]
                                                    , [ p, '.', q ]
                                                    ]
                                        in
                                        flip List.filter model.posts <|
                                            \post ->
                                                String.contains (String.fromList [ p, '.', ' ', q ]) (getText post)
                                                    || List.any (\word -> List.any ((==) word) initials)
                                                        (Regex.split whitespace (getText post))

                                    _ ->
                                        []

                            simpleFilter =
                                List.filter (getText >> String.contains query) model.posts
                        in
                        List.uniqueBy .src
                            (initialsFilter ++ simpleFilter)
              }
            , Cmd.none
            )

        ImageChanged index ->
            ( { model | img = Just index }, Cmd.none )

        SwitchImage by ->
            ( { model
                | img =
                    Maybe.map
                        (\imgIndex -> clamp 0 (List.length model.filtered) (imgIndex + by))
                        model.img
              }
            , Cmd.none
            )

        ClosePreview ->
            ( { model | img = Nothing }, Cmd.none )


fetchPosts : Cmd Msg
fetchPosts =
    Http.get
        { url = "data.json"
        , expect = Http.expectJson GotPosts (Decode.list postDecoder)
        }


view : Model -> Html Msg
view model =
    div []
        [ flip Html.viewMaybe model.img <|
            \imgIndex ->
                div [ Attr.id "preview" ]
                    [ img [ Attr.src "close.svg", Event.onClick ClosePreview ] []
                    , div [ Attr.id "box" ]
                        [ span [ Attr.class "control" ] <|
                            [ Html.viewIf (imgIndex > 0) <|
                                img [ Attr.src "left.svg", Event.onClick (SwitchImage -1) ] []
                            ]
                        , img
                            [ Attr.id "picture"
                            , model.filtered
                                |> List.getAt imgIndex
                                |> Maybe.map .src
                                |> Maybe.withDefault ""
                                |> Attr.src
                            ]
                            []
                        , span [ Attr.class "control" ] <|
                            [ Html.viewIf (imgIndex < List.length model.filtered - 1) <|
                                img [ Attr.src "right.svg", Event.onClick (SwitchImage 1) ] []
                            ]
                        ]
                    ]
        , div [ Attr.id "main" ]
            [ header [] [ a [ Attr.href "https://porgovskadrbna.cz" ] [ h1 [] [ text "porgovská drbna" ] ] ]
            , p [] [ text "Vyhledejte ve stories drbny" ]
            , input [ Event.onInput NewQuery, Attr.autofocus True ] []
            , if model.failed then
                p [] [ text "Sorry, borci, zas to nějak nejede…" ]

              else if List.isEmpty model.posts then
                p [] [ text "Sháním drby od drbny. Posečkejte prosím chvilinku…" ]

              else
                Keyed.node "div" [ Attr.id "pictures" ] <|
                    flip List.indexedMap model.filtered <|
                        \index post ->
                            ( post.src
                            , img
                                [ Attr.src post.src
                                , Attr.alt post.text
                                , Attr.attribute "loading" "lazy"
                                , Event.onClick (ImageChanged index)
                                ]
                                []
                            )
            ]
        ]
