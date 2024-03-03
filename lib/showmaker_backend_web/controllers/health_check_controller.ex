defmodule ShowmakerBackendWeb.HealthCheckController do
  @moduledoc """
  Endpoint to visualize the API status
  """

  use ShowmakerBackendWeb, :controller

  def index(conn, _params) do
    conn
    |> put_status(:ok)
    |> render(:index)
  end
end
