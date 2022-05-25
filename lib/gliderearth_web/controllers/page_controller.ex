defmodule GliderearthWeb.PageController do
  use GliderearthWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
