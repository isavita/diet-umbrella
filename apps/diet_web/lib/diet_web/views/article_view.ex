defmodule DietWeb.ArticleView do
  use DietWeb, :view
  import DietWeb.SharedView

  def type_select_options do
    Diet.Multimedia.supported_article_types()
  end
end
