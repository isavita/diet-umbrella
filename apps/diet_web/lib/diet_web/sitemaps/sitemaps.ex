defmodule DietWeb.Sitemaps do
  use Sitemap

  alias Diet.Multimedia
  alias DietWeb.Endpoint
  alias DietWeb.Router.Helpers, as: Routes

  @adapter Sitemap.Adapter.Virtual
  @host "https://weighthater.com"

  def generate do
    create adapter: @adapter, host: @host, compresion: false do
      add Routes.page_path(Endpoint, :index), priority: 0.9, changefreq: "monthly"

      published_videos = Multimedia.list_published_videos(limit: 10_000)
      newest_video = Enum.max_by(published_videos, & &1.published_at)
      add Routes.page_path(Endpoint, :newsfeed), priority: 0.9, changefreq: "always", lastmod: newest_video.published_at

      add Routes.user_path(Endpoint, :new), priority: 0.7, changefreq: "monthly"
      add Routes.session_path(Endpoint, :new), priority: 0.7, changefreq: "monthly"

      for video <- published_videos do
        add Routes.watch_path(Endpoint, :show, video), priority: 0.5, changefreq: "hourly", lastmod: video.published_at
      end
    end
  end
end
