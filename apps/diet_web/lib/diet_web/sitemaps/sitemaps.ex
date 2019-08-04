defmodule DietWeb.Sitemaps do
  use Sitemap

  alias Diet.Multimedia
  alias DietWeb.Router.Helpers, as: Routes
  alias DietWeb.Endpoint


  def generate do
    create adapter: Sitemap.Adapter.Virtual, host: "https://weighthater.com", files_path: Path.join([:code.priv_dir(:diet_web), "static", "sitemaps"]), public_path: "sitemaps" do
      published_videos = Multimedia.list_published_videos(limit: 10_000)
      for video <- published_videos do
        add Routes.page_path(Endpoint, :newsfeed), priority: 0.5, changefreq: "hourly", lastmod: video.published_at
      end

      newest_video = Enum.max_by(published_videos, & &1.published_at)
      add Routes.page_path(Endpoint, :newsfeed), priority: 0.9, changefreq: "always", lastmod: newest_video.published_at
    end
  end
end
