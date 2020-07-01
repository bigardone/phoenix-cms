defmodule PhoenixCmsWeb.Router do
  use PhoenixCmsWeb, :router
  import Phoenix.LiveDashboard.Router, only: [live_dashboard: 2]

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {PhoenixCmsWeb.LayoutView, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", PhoenixCmsWeb do
    pipe_through :browser

    live "/", PageLive
    live "/blog", ArticlesLive
    live "/blog/:id/:slug", ShowArticleLive
  end

  if Mix.env() == :dev do
    scope "/" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: PhoenixCmsWeb.Telemetry
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", PhoenixCmsWeb do
  #   pipe_through :api
  # end
end
