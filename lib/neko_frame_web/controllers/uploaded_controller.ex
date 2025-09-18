defmodule NekoFrameWeb.UploadedController do
  use NekoFrameWeb, :controller

  def fetch(conn, %{"filename" => file}) do
    path = Path.join(NekoFrame.upload_path(), file)

    if File.exists?(path) do
      send_file(conn, :ok, path)
    else
      send_resp(conn, :not_found, "")
    end
  end
end
