defmodule DietWeb.Channels.UserSocketTest do
  use DietWeb.ChannelCase, async: true

  alias DietWeb.UserSocket

  test "socket authentication with valid token" do
    token = Phoenix.Token.sign(@endpoint, "user socket", "123")

    assert {:ok, socket} = connect(UserSocket, %{"token" => token})
    assert socket.assigns.user_id == "123"
  end

  test "socket authentication with invalid token" do
    assert :error = connect(UserSocket, %{})
    assert :error = connect(UserSocket, %{"token" => "invalid token"})
  end
end
