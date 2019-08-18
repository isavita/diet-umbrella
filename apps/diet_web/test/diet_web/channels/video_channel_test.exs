defmodule DietWeb.Channels.VideoChannelTest do
  use DietWeb.ChannelCase

  alias DietWeb.Support.Factory

  setup do
    user = Factory.create_user(name: "Gary")
    video = Factory.create_video(%{title: "Testing"}, user)
    token = Phoenix.Token.sign(@endpoint, "user socket", user.id)
    {:ok, socket} = connect(DietWeb.UserSocket, %{"token" => token})

    {:ok, socket: socket, video: video, user: user}
  end

  test "join replies with video annotations", %{socket: socket, video: vid, user: user} do
    for body <- ~w(one two) do
      Diet.Multimedia.annotate_video(user, vid.id, %{body: body, at: 0})
    end

    {:ok, reply, socket} = subscribe_and_join(socket, "videos:#{vid.id}", %{})

    assert socket.assigns.video_id == vid.id
    assert %{annotations: [%{body: "one"}, %{body: "two"}]} = reply
  end

  test "inserting new annotations", %{socket: socket, video: vid} do
    {:ok, _, socket} = subscribe_and_join(socket, "videos:#{vid.id}", %{})
    ref = push(socket, "new_annotation", %{body: "the body", at: 0})
    assert_reply ref, :ok, %{}
    assert_broadcast "new_annotation", %{}
  end

  test "new annotations triggers InfoSys", %{socket: socket, video: vid} do
    Factory.create_user(%{username: "wolfram", password: "supersecret"})
    {:ok, _, socket} = subscribe_and_join(socket, "videos:#{vid.id}", %{})
    ref = push(socket, "new_annotation", %{body: "1 + 1", at: 123})
    assert_reply ref, :ok, %{}
    assert_broadcast "new_annotation", %{body: "1 + 1", at: 123}
    assert_broadcast "new_annotation", %{body: "2", at: 123}
  end
end
