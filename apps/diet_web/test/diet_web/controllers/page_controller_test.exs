defmodule DietWeb.PageControllerTest do
  use DietWeb.ConnCase

  describe "index/2" do
    test "GET /", %{conn: conn} do
      conn = get(conn, "/")
      assert html_response(conn, 200) =~ "Welcome to Weight Hater!"
    end
  end

  describe "newsfeed/2" do
    test "GET /", %{conn: conn} do
      conn = get(conn, "/newsfeed")
      assert html_response(conn, 200)
    end
  end
end
