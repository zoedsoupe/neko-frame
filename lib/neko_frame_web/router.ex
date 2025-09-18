defmodule NekoFrameWeb.Router do
  use NekoFrameWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {NekoFrameWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", NekoFrameWeb do
    pipe_through :browser

    live "/", CardLive
  end
end
