defmodule DietWeb.ArticleView do
  use DietWeb, :view

  def type_select_options do
    Diet.Multimedia.supported_article_types()
  end

  def category_select_options(categories) do
    for category <- categories, do: {category.name, category.id}
  end

  def default_published_at(%{data: %{published_at: published_at}}),
    do: published_at || DateTime.utc_now()
end
