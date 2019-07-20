defmodule DietWeb.Api.VideoControllerTest do
  use DietWeb.ConnCase, async: true

  test "index/1 rendres all videos in the system", %{conn: conn} do
    video = Factory.create_video()

    response =
      conn
      |> get(Routes.api_video_path(conn, :index))
      |> json_response(200)

    video_json = hd(response["data"]["videos"])

    assert video_json == %{
             "id" => video.id,
             "title" => video.title,
             "description" => video.description,
             "url" => video.url,
             "slug" => video.slug,
             "published_at" => video.published_at,
             "user_id" => video.user_id,
             "category_id" => video.category_id
           }
  end
end
