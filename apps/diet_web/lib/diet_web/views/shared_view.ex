defmodule DietWeb.SharedView do
  def category_select_options(categories) do
    for category <- categories, do: {category.name, category.id}
  end

  def tags_select_options(tags) do
    for tag <- tags, do: {tag.name, tag.id}
  end

  def selected_tags(%{data: %{tags: tags}}) do
    cond do
      Ecto.assoc_loaded?(tags) -> Enum.map(tags, & &1.id)
      true -> []
    end
  end

  def default_published_at(%{data: %{published_at: published_at}}),
    do: published_at || DateTime.utc_now()
end
