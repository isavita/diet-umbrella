defmodule DietWeb.Support.Factory do
  alias Diet.{Accounts, Multimedia}

  @user_attrs %{
    name: "Jane Doe",
    password: "nosecret"
  }

  @video_attrs %{
    title: "A title",
    description: "A descripton",
    url: "https://www.youtube.com/watch?v=randomvideo"
  }

  def create_user(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(put_random_username(@user_attrs))
      |> Accounts.register_user()

    user
  end

  def create_video(attrs \\ %{}, user \\ create_user())

  def create_video(attrs, %Accounts.User{} = user) do
    attrs = Enum.into(attrs, @video_attrs)
    {:ok, video} = Multimedia.create_video(user, attrs)

    video
  end

  def login(%{conn: conn, login_as: username}) do
    user = Diet.Support.Factory.create_user(username: username)
    {Plug.Conn.assign(conn, :current_user, user), user}
  end

  def login(%{conn: conn}), do: {conn, :logged_out}

  defp put_random_username(attrs) do
    Map.put(attrs, :username, "jane#{System.unique_integer([:positive])}")
  end
end
