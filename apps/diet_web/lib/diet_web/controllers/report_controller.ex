defmodule DietWeb.ReportController do
  use DietWeb, :controller

  alias Diet.Multimedia

  def create(conn, %{"report" => params}) do
    user_id = conn.assigns.current_user.id
    reportable_id = String.to_integer(params["reportable_id"])
    attrs = %{params["reason"] => true}

    case Multimedia.report(user_id, reportable_id, params["reportable_type"], attrs) do
      {:ok, _report} ->
        conn
        |> put_flash(:info, "The post has been reported!")
        |> redirect(to: Routes.page_path(conn, :newsfeed))

      {:error, _reason} ->
        conn
        |> put_flash(:error, "You already have reported this post!")
        |> redirect(to: Routes.page_path(conn, :newsfeed))
    end
  end
end
