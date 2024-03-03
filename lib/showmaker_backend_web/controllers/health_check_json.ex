defmodule ShowmakerBackendWeb.HealthCheckJSON do
  @moduledoc """
  Module responsible for rendering health check json response
  """

  alias ShowmakerBackend.AppInfo

  def index(_params) do
    start_time = AppInfo.get_start_time()

    %{
      app_name: AppInfo.app_name(),
      elapsed_time: "#{AppInfo.get_elapsed_time(start_time) / 1000}s",
      start_time: start_time,
      version: AppInfo.app_version()
    }
  end
end
