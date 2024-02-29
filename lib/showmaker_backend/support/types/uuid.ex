defmodule ShowmakerBackend.Support.Types.UUID do
  @moduledoc false

  use Ecto.ParameterizedType

  @prefix_separator "_"

  @typedoc """
  A hex-encoded UUID string.
  """
  @type t :: <<_::288>>

  @typedoc """
  A raw binary representation of a UUID.
  """
  @type raw :: <<_::128>>

  @doc false
  def type(_params), do: :uuid

  @doc false
  def init(opts), do: Enum.into(opts, %{})

  @doc """
  Casts to a UUID.
  """
  def cast(raw, _params), do: UUIDv7.cast(raw)

  @doc """
  Same as `cast/1` but raises `Ecto.CastError` on invalid arguments.
  """
  def cast!(raw, params) do
    case cast(raw, params) do
      {:ok, uuid} -> uuid
      :error -> raise Ecto.CastError, type: __MODULE__, value: raw
    end
  end

  @doc """
  Converts a binary UUID into a string.
  """
  def load(raw, _loader, params) do
    prefix = Map.get(params, :prefix)

    with {:ok, uuid} <- UUIDv7.load(raw) do
      {:ok, append_prefix(uuid, prefix)}
    end
  end

  @doc """
  Converts a string representing a UUID into a raw binary.
  """

  def dump(uuid, _dumper, _params) when is_binary(uuid) do
    with {:ok, uuid} <- dump_prefix(uuid) do
      UUIDv7.dump(uuid)
    end
  end

  def dump(uuid, _dumper, _params) when uuid === "" do
    {:ok, nil}
  end

  def dump(nil, _, _), do: {:ok, nil}

  def dump(_, _, _), do: :error

  def equal?(a, b, _params) do
    a === b
  end

  def autogenerate(params) do
    prefix = Map.get(params, :prefix)
    uuid = generate()

    append_prefix(uuid, prefix)
  end

  def generate, do: UUIDv7.generate()

  # Private helpers

  defp append_prefix(uuid, nil) when is_binary(uuid) do
    {:ok, String.downcase(uuid)}
  end

  defp append_prefix(uuid, prefix) when is_binary(uuid) do
    uuid =
      uuid
      |> String.split(@prefix_separator)
      |> case do
        [_prev_prefix, uuid] -> uuid
        [uuid] -> uuid
      end

    {:ok, String.downcase("#{prefix}#{@prefix_separator}#{uuid}")}
  end

  defp append_prefix(_uuid, _prefix), do: :error

  defp dump_prefix(uuid) when is_binary(uuid) do
    uuid =
      uuid
      |> String.split(@prefix_separator)
      |> case do
        [_prefix, uuid] -> uuid
        [uuid] -> uuid
      end

    {:ok, String.downcase(uuid)}
  end

  defp dump_prefix(_uuid), do: :error
end
