defmodule SmashulWeb.PageController do
  use SmashulWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
