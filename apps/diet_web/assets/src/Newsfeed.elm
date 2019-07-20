module Newsfeed exposing (main)

import Browser
import Html exposing (div, h2, iframe, li, text, ul)
import Html.Attributes exposing (..)
import Http
import Json.Decode as Decode



-- Main


main =
    Browser.element { init = init, subscriptions = subscriptions, update = update, view = view }



-- Model


type Model
    = LoadingPopularVideos
    | SuccessGetPopularVideos (List Video)
    | FailureGetPopularVideos


init : () -> ( Model, Cmd Msg )
init _ =
    ( LoadingPopularVideos, getPopularVideos )



-- Update


type Msg
    = GotPopularVideos (Result Http.Error (List Video))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotPopularVideos result ->
            case result of
                Ok videos ->
                    ( SuccessGetPopularVideos videos, Cmd.none )

                Err _ ->
                    ( FailureGetPopularVideos, Cmd.none )



-- Subscriptions


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- View


view model =
    let
        popularVideosDiv videos =
            div []
                [ h2 [] [ text "Popular videos" ]
                , ul [ class "popular-videos" ]
                    (List.map viewVideo videos)
                ]
    in
    case model of
        FailureGetPopularVideos ->
            text "There was an error on loading the newsfeed"

        LoadingPopularVideos ->
            text "Loading..."

        SuccessGetPopularVideos videos ->
            popularVideosDiv videos


viewVideo video =
    li []
        [ text video.title
        , iframe [ class "iframe-player", src (youtubeEmbeddedUrl video.url) ] []
        ]


youtubeEmbeddedUrl : String -> String
youtubeEmbeddedUrl youtubeUrl =
    String.replace "/watch?v=" "/embed/" youtubeUrl



-- HTTP REQUESTS


type alias Video =
    { id : Int
    , url : String
    , title : String
    , description : Maybe String
    , slug : Maybe String
    , published_at : Maybe String
    , user_id : Maybe Int
    , category_id : Int
    }


getPopularVideos : Cmd Msg
getPopularVideos =
    Http.get
        { url = "/api/popular_videos"
        , expect = Http.expectJson GotPopularVideos videosDecoder
        }


videoDecoder : Decode.Decoder Video
videoDecoder =
    Decode.map8 Video
        (Decode.field "id" Decode.int)
        (Decode.field "url" Decode.string)
        (Decode.field "title" Decode.string)
        (Decode.maybe (Decode.field "description" Decode.string))
        (Decode.maybe (Decode.field "slug" Decode.string))
        (Decode.maybe (Decode.field "published_at" Decode.string))
        (Decode.maybe (Decode.field "user_id" Decode.int))
        (Decode.field "category_id" Decode.int)


videoListDecoder : Decode.Decoder (List Video)
videoListDecoder =
    Decode.list videoDecoder


videosDecoder : Decode.Decoder (List Video)
videosDecoder =
    Decode.field "data" (Decode.field "videos" videoListDecoder)
