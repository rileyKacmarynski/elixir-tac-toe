defmodule ClientAppWeb.PageController do
  use ClientAppWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def login(conn, _params) do
    render(conn, "login.html")
  end

  def join(conn, %{ "params" => %{"username" => username}}) do

    case String.match?(username, ~r/^[[:alnum:]]+$/) do
      true ->
        conn
        |> put_session(:current_user, username)
        |> redirect(to: "/")
      false ->
        conn
        |> put_flash(:error, "Username must be alphanumeric.")
        |> render("login.html")
    end


  end
end
