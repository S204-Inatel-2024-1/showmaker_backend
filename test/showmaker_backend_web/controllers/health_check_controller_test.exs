defmodule ShowmakerBackendWeb.HealthCheckControllerTest do
  @moduledoc """
  Module in charge of test HealthCheckController
  """

  use ShowmakerBackendWeb.ConnCase

  test "GET /api/health_check", %{conn: conn} do
    conn = get(conn, ~p"/api/health_check")

    assert %{
             "app_name" => "Showmaker backend",
             "elapsed_time" => _elapsed_time,
             "start_time" => _start_time,
             "version" => "0.1.0"
           } = json_response(conn, 200)
  end
end
