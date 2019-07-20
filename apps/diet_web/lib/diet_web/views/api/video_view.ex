defmodule DietWeb.Api.VideoView do
  use DietWeb, :view

  def render("index.json", %{videos: videos}) do
    %{data: %{videos: render_many(videos, __MODULE__, "video.json")}}
  end

  def render("video.json", %{video: video}) do
    %{
      id: video.id,
      url: video.url,
      title: video.title,
      description: video.description,
      slug: video.slug,
      published_at: video.published_at,
      user_id: video.user_id,
      category_id: video.category_id
    }
  end
end
