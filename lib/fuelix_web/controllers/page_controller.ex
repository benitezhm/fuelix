defmodule FuelixWeb.PageController do
  use FuelixWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
