defmodule DietWeb.VideoViewTest do
  use DietWeb.ConnCase, async: true

  import Phoenix.View

  alias Diet.Multimedia
  alias Diet.Multimedia.{Category, Video}
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

    assert String.contains?(content, "Listing Videos")

    for video <- videos do
      assert String.contains?(content, video.title)
    end
  end

  test "renders new.html", %{conn: conn} do
    changeset = Multimedia.change_video(%Video{})

    categories = [
      %Category{id: "1", name: "Comedy"},
      %Category{id: "2", name: "Science"}
    ]

    content =
      render_to_string(
        VideoView,
        "new.html",
        conn: conn,
        changeset: changeset,
        categories: categories
      )

    assert String.contains?(content, "New Video")
    assert String.contains?(content, "Title")
    assert String.contains?(content, "Description")
    assert String.contains?(content, "Url")

    for category <- categories do
      assert String.contains?(content, category.id)
      assert String.contains?(content, category.name)
    end
  end
end
