defmodule ShowmakerBackend.Support.Behaviours.ObjectStorage do
  @moduledoc """
  Module responsible to abstract the object storage interaction
  """

  @callback insert_object(String.t(), String.t(), String.t()) ::
              {:ok, String.t()} | {:error, term()}

  @callback insert_stream(Enumerable.t(), String.t(), String.t()) ::
              {:ok, String.t()} | {:error, term()}

  def get_module(provider) do
    :showmaker_backend
    |> Application.fetch_env!(:behaviours)
    |> Keyword.get(:object_storage)
    |> Keyword.get(provider)
    |> case do
      nil -> {:error, :module_unavailable}
      module -> {:ok, module}
    end
  end
end
