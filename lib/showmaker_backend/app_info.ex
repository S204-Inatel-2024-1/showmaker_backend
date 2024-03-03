defmodule ShowmakerBackend.AppInfo do
  @moduledoc """
  Module responsible for general app information
  """

  @app :showmaker_backend
  @table __MODULE__
  @start_time_key :start_time
  @default_start_time DateTime.from_unix!(0)

  def app_name do
    @app
    |> Application.spec(:description)
    |> to_string()
    |> Phoenix.Naming.humanize()
  end

  def app_version do
    @app
    |> Application.spec(:vsn)
    |> to_string()
    |> Phoenix.Naming.humanize()
  end

  def get_elapsed_time(start_time, opts \\ []) do
    unit = Keyword.get(opts, :unit, :millisecond)
    DateTime.diff(DateTime.utc_now(), start_time, unit)
  end

  def get_start_time do
    @table
    |> :ets.lookup(@start_time_key)
    |> Keyword.get(@start_time_key, @default_start_time)
  end

  def set_start_time do
    :ets.new(@table, [:set, :public, :named_table])

    start_time = DateTime.utc_now()
    :ets.insert(@table, {@start_time_key, start_time})
  end
end
