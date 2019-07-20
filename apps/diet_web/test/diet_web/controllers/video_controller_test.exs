defmodule DietWeb.VideoControllerTest do
  use DietWeb.ConnCase, async: true

  describe "without logged-in user" do
    test "requires user authentication on all actions", %{conn: conn} do
      Enum.each(
        [
          get(conn, Routes.video_path(conn, :index)),
          get(conn, Routes.video_path(conn, :new)),
          get(conn, Routes.video_path(conn, :show, "123")),
          get(conn, Routes.video_path(conn, :edit, "123")),
          post(conn, Routes.video_path(conn, :create, %{})),
          put(conn, Routes.video_path(conn, :update, "123", %{})),
          delete(conn, Routes.video_path(conn, :delete, "123"))
        ],
        fn conn ->
          assert redirected_to(conn, 302) =~ "/"
          assert conn.halted
        end
      )
    end

    test "authorizes actions against access by other users", %{conn: conn} do
      owner = Factory.create_user()
      video = Factory.create_video(%{}, owner)
      non_owner = Factory.create_user()
      conn = assign(conn, :current_user, non_owner)

      assert_error_sent(:not_found, fn ->
        get(conn, Routes.video_path(conn, :show, video))
      end)

      assert_error_sent(:not_found, fn ->
        get(conn, Routes.video_path(conn, :edit, video))
      end)

      assert_error_sent(:not_found, fn ->
        put(conn, Routes.video_path(conn, :update, video, video: %{id: video.id}))
      end)

      assert_error_sent(:not_found, fn ->
        delete(conn, Routes.video_path(conn, :delete, video))
      end)
    end
  end

  describe "with logged-in user" do
    alias Diet.Multimedia

    @create_attrs %{url: "http://youtu.be", title: "vid", description: "a vid"}

    @invalid_attrs %{title: "invalid"}

    setup %{conn: conn} do
      user = Factory.create_user()
      conn = assign(conn, :current_user, user)

      {:ok, conn: conn, user: user}
    end

    defp video_count, do: Enum.count(Multimedia.list_videos())

    test "index/1 lists all user's videos", %{conn: conn, user: user} do
      user_video = Factory.create_video(%{title: "cat video"}, user)
      other_video = Factory.create_video(%{title: "dog video"})

      conn = get(conn, Routes.video_path(conn, :index))

      assert html_response(conn, 200) =~ ~r/Listing Videos/
      assert String.contains?(conn.resp_body, user_video.title)
      refute String.contains?(conn.resp_body, other_video.title)
    end

    test "creates user video and redirects", %{conn: conn, user: user} do
      create_conn = post conn, Routes.video_path(conn, :create), video: @create_attrs
      assert %{id: id} = redirected_params(create_conn)

      assert redirected_to(create_conn) ==
               Routes.video_path(create_conn, :show, id)

      conn = get(conn, Routes.video_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Video"
      assert Multimedia.get_video!(id).user_id == user.id
    end

    test "does not create vid, renders errors when invalid", %{conn: conn} do
      count_before = video_count()
      conn = post conn, Routes.video_path(conn, :create), video: @invalid_attrs
      assert html_response(conn, 200) =~ "check the errors"
      assert video_count() == count_before
    end
  end
end
