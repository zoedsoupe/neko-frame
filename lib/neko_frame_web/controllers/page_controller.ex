defmodule NekoFrameWeb.PageController do
  use NekoFrameWeb, :controller

  def home(conn, _) do
    conn
    |> put_resp_header("content-type", "text/plain")
    |> send_resp(:ok, "Hello world!")
  end
end
