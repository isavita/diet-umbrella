defmodule DietWeb.SitemapController do
  use DietWeb, :controller

  def sitemap(conn, params) do
    xml =
      DietWeb.Sitemaps.generate()
      |> Enum.join()
      |> String.replace(~r{<sitemapindex[^>]+>\n}, "")
      |> String.replace(~r{</sitemapindex>\n}, "")

    conn
    |> put_resp_content_type("application/xml")
    |> send_resp(200, xml)
  end
end
