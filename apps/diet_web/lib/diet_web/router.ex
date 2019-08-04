defmodule DietWeb.Router do
  use DietWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug DietWeb.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", DietWeb do
    pipe_through :browser

    get "/", PageController, :index
    get "/newsfeed", PageController, :newsfeed
    resources "/users", UserController, only: [:index, :show, :new, :create]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    get "/watch/:id", WatchController, :show

    get "/sitemap", SitemapController, :sitemap
  end

  scope "/manage", DietWeb do
    pipe_through [:browser, :authenticate_user]

    resources "/videos", VideoController
  end

  scope "/admin", DietWeb do
    pipe_through [:browser, :authenticate_user, :authenticate_admin_user]

    get "/videos", AdminController, :videos
    patch "/videos/:id/actions/publish", AdminController, :publish
    patch "/videos/:id/actions/unpublish", AdminController, :unpublish
  end
end
