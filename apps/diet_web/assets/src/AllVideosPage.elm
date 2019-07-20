module AllVideosPage exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Http
import Json.Decode as Decode



-- Main


main =
    Browser.sandbox { init = (), view = \x -> p [] [], update = \x y -> () }



{-
   main =
       Browser.element
           { init = init
           , subscriptions = subscriptions
           , update = update
           , view = view
           }



   -- Model


   type Model
       = FailureGetVideos
       | LoadingVideos
       | SuccessGetVideos (List Video)
       | FailureUnpublishVideo
       | SuccessUnpublishVideo


   init : () -> ( Model, Cmd Msg )
   init _ =
       ( LoadingVideos, getVideos )



   -- Update


   type Msg
       = GotVideos (Result Http.Error (List Video))
       | UnpublishedVideo (Result Http.Error ())


   update : Msg -> Model -> ( Model, Cmd Msg )
   update msg model =
       case msg of
           GotVideos result ->
               case result of
                   Ok videos ->
                       ( SuccessGetVideos videos, Cmd.none )

                   Err _ ->
                       ( FailureGetVideos, Cmd.none )

           UnpublishedVideo result ->
               case result of
                   Ok _ ->
                       ( SuccessUnpublishVideo, Cmd.none )

                   Err _ ->
                       ( FailureUnpublishVideo, Cmd.none )



   -- Subscriptions


   subscriptions : Model -> Sub Msg
   subscriptions _ =
       Sub.none



   -- View


   view model =
       let
           videosDiv videos =
               div []
                   [ ul []
                       (List.map
                           (\v ->
                               li []
                                   [ watchLink v.id v.title
                                   , unpublishVideoButton v.id
                                   ]
                           )
                           videos
                       )
                   ]
       in
       case model of
           FailureGetVideos ->
               text "There was an error on load all videos."

           LoadingVideos ->
               text "Loading..."

           SuccessGetVideos videos ->
               videosDiv videos


   watchLink : Int -> String -> Html Msg
   watchLink id title =
       a [ href ("/watch/" ++ String.fromInt id) ] [ text title ]


   unpublishVideoButton id =
       button [ onClick (unpublishVideo id) ] [ text "Unpublish" ]



   -- Http


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


   getVideos : Cmd Msg
   getVideos =
       Http.get
           { url = "/api/videos"
           , expect = Http.expectJson GotVideos videosDecoder
           }


   unpublishVideo : Int -> Cmd Msg
   unpublishVideo videoId =
       Http.request
           { method = "PATCH"
           , headers = []
           , url = "/admin/videos/" ++ String.fromInt videoId ++ "/actions/unpublish"
           , body = Http.emptyBody
           , expect = Http.expectWhatever UnpublishedVideo
           , timeout = Nothing
           , tracker = Nothing
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
-}
