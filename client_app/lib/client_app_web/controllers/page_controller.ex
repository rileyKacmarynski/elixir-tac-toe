defmodule ClientAppWeb.PageController do
  use ClientAppWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
