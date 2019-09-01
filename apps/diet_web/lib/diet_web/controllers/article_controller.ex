defmodule DietWeb.ArticleController do
  use DietWeb, :controller

  alias Diet.Multimedia
  alias Diet.Multimedia.Article

  plug :load_category when action in [:new, :create, :edit, :update]

  def index(conn, _params, current_user) do
    articles = Multimedia.list_articles()
    render(conn, "index.html", articles: articles)
  end

  def new(conn, _params, current_user) do
    changeset = Multimedia.change_article(%Article{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"article" => article_params}, current_user) do
    case Multimedia.create_article(article_params) do
      {:ok, article} ->
        conn
        |> put_flash(:info, "Article created successfully.")
        |> redirect(to: Routes.article_path(conn, :show, article))

      {:error, %Ecto.Changeset{} = changeset} ->
        categories = Multimedia.list_categories()
        render(conn, "new.html", changeset: changeset, categories: categories)
    end
  end

  def show(conn, %{"id" => id}, current_user) do
    article = Multimedia.get_article!(id)
    render(conn, "show.html", article: article)
  end

  def edit(conn, %{"id" => id}, current_user) do
    article = Multimedia.get_article!(id)
    changeset = Multimedia.change_article(article)
    render(conn, "edit.html", article: article, changeset: changeset)
  end

  def update(conn, %{"id" => id, "article" => article_params}, current_user) do
    article = Multimedia.get_article!(id)

    case Multimedia.update_article(article, article_params) do
      {:ok, article} ->
        conn
        |> put_flash(:info, "Article updated successfully.")
        |> redirect(to: Routes.article_path(conn, :show, article))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", article: article, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}, current_user) do
    article = Multimedia.get_article!(id)
    {:ok, _article} = Multimedia.delete_article(article)

    conn
    |> put_flash(:info, "Article deleted successfully.")
    |> redirect(to: Routes.article_path(conn, :index))
  end

  def action(conn, _) do
    args = [conn, conn.params, conn.assigns.current_user]
    apply(__MODULE__, action_name(conn), args)
  end

  defp load_category(conn, _) do
    assign(conn, :categories, Multimedia.list_ordered_categories())
  end
end
