defmodule DietWeb.AdminControllerTest do
  use DietWeb.ConnCase, async: true

  alias Diet.Accounts
  alias Diet.Multimedia

  describe "with logged-in user that is not admin" do
    setup %{conn: conn} do
      user = Factory.create_user()
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    test "requires admin authentication on all actions", %{conn: conn} do
      Enum.each(
        [
          get(conn, Routes.admin_path(conn, :videos)),
          patch(conn, Routes.admin_path(conn, :unpublish, 1))
        ],
        fn conn ->
          assert conn.status == 403
          assert conn.halted
        end
      )
    end
  end

  describe "with logged-in admin user" do
    setup %{conn: conn} do
      user = Factory.create_user() |> Accounts.make_admin!()
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn}
    end

    test "renders all videos page", %{conn: conn} do
      conn = get(conn, Routes.admin_path(conn, :videos))
      assert html_response(conn, 200) =~ "All Videos:"
    end

    test "publish given video", %{conn: conn} do
      video = Factory.create_video()
      patch(conn, Routes.admin_path(conn, :publish, video.id))

      assert Multimedia.get_video!(video.id).published_at
    end

    test "unpublish given video", %{conn: conn} do
      video = Factory.create_video(%{published_at: DateTime.utc_now()})
      patch(conn, Routes.admin_path(conn, :unpublish, video.id))

      refute Multimedia.get_video!(video.id).published_at
    end
  end
end
