defmodule DietWeb.UserView do
  use DietWeb, :view

  def first_name(%{name: name}) do
    name
    |> String.split(~r/\s+/)
    |> Enum.at(0)
  end

  def render("user.json", %{user: user}) do
    %{
      id: user.id,
      username: user.username,
      name: user.name
    }
  end
end
