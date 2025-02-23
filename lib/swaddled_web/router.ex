defmodule SwaddledWeb.Router do
  use SwaddledWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {SwaddledWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SwaddledWeb do
    pipe_through :browser

    live "/", DashboardLive.Index
    live "/import", ImportLive.Index
    live "/import/genres", ImportLive.Genres
  end

  # Other scopes may use custom stacks.
  # scope "/api", SwaddledWeb do
  #   pipe_through :api
  # end
end
