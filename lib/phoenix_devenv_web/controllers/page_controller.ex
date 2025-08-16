defmodule PhoenixDevenvWeb.PageController do
  use PhoenixDevenvWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
