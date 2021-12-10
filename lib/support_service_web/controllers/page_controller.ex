defmodule SupportServiceWeb.PageController do
  use SupportServiceWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
