defmodule DietWeb.SitemapController do
  use DietWeb, :controller

  def sitemap(conn, params) do
    xml = DietWeb.Sitemaps.generate() |>  Enum.join()

    conn
    |> put_resp_content_type("text/xml")
    |> send_resp(200, xml)
  end
end
