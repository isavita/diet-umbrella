defmodule DietWeb.VideoViewTest do
  use DietWeb.ConnCase, async: true

  import Phoenix.View

  alias Diet.Multimedia
  alias Diet.Multimedia.{Tag, Video}
  alias DietWeb.VideoView

  test "renders index.html", %{conn: conn} do
    videos = [
      %Video{id: 1, title: "cat video"},
      %Video{id: 2, title: "dog video"}
    ]

    content =
      render_to_string(
        VideoView,
        "index.html",
        conn: conn,
        videos: videos
      )

    for video <- videos do
      assert String.contains?(content, video.title)
    end
  end

  test "renders new.html", %{conn: conn} do
    changeset = Multimedia.change_video(%Video{})

    tags = [
      %Tag{id: "1", name: "Comedy"},
      %Tag{id: "2", name: "Science"}
    ]

    content =
      render_to_string(
        VideoView,
        "new.html",
        conn: conn,
        changeset: changeset,
        tags: tags
      )

    assert String.contains?(content, "New Video")
    assert String.contains?(content, "Title")
    assert String.contains?(content, "Description")
    assert String.contains?(content, "Url")

    for tag <- tags do
      assert String.contains?(content, tag.id)
      assert String.contains?(content, tag.name)
    end
  end
end
