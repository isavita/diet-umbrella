defmodule DietWeb.PageView do
  use DietWeb, :view

  def embedded_url(video) do
    String.replace(video.url, "/watch?v=", "/embed/")
  end
end
