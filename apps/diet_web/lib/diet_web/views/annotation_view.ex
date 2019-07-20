defmodule DietWeb.AnnotationView do
  use DietWeb, :view

  alias DietWeb.UserView

  def render("annotation.json", %{annotation: annotation}) do
    %{
      id: annotation.id,
      body: annotation.body,
      at: annotation.at,
      user: render_one(annotation.user, UserView, "user.json")
    }
  end
end
