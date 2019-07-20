defmodule DietWeb.AuthTest do
  use DietWeb.ConnCase, async: true

  alias DietWeb.Auth
  alias Diet.Accounts.User

  setup %{conn: conn} do
    conn =
      conn
      |> bypass_through(DietWeb.Router, :browser)
      |> get("/")

    {:ok, conn: conn}
  end

  describe "call/2" do
    test "places user from session into assigns", %{conn: conn} do
      user = Factory.create_user()

      conn =
        conn
        |> put_session(:user_id, user.id)
        |> Auth.call(Auth.init([]))

      assert conn.assigns.current_user.id == user.id
    end

    test "with no session sets current_user to `nil`", %{conn: conn} do
      conn = Auth.call(conn, Auth.init([]))
      refute conn.assigns.current_user
    end
  end

  describe "authenticate_user/2" do
    test "authenticate_user halts when no current_user exists", %{conn: conn} do
      conn = Auth.authenticate_user(conn, [])

      assert conn.halted
    end

    test "authenticate_user continues when the current_user exists", %{conn: conn} do
      conn =
        conn
        |> assign(:current_user, %User{})
        |> Auth.authenticate_user([])

      refute conn.halted
    end
  end

  describe "login/2" do
    test "login puts the user in the session", %{conn: conn} do
      login_conn =
        conn
        |> Auth.login(%User{id: 123})
        |> send_resp(:ok, "")

      next_conn = get(login_conn, "/")
      assert get_session(next_conn, :user_id) == 123
    end
  end

  describe "logout/2" do
    test "logout drops the session", %{conn: conn} do
      logout_conn =
        conn
        |> put_session(:user_id, 123)
        |> Auth.logout()
        |> send_resp(:ok, "")

      next_conn = get(logout_conn, "/")
      refute get_session(next_conn, :user_id)
    end
  end
end
