defmodule ClientAppWeb.Router do
  use ClientAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ClientAppWeb do
    pipe_through :browser

    live "/", LobbyLive
    live "/accept-invite/:from", LobbyLive, as: "accept_invite_live"
    live "/play/:game", PlayLive
    get "/login", PageController, :login
    post "/login", PageController, :join
  end

  # Other scopes may use custom stacks.
  # scope "/api", ClientAppWeb do
  #   pipe_through :api
  # end
end
