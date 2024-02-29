defmodule ShowmakerBackend.Support.Types.UUIDTest do
  @moduledoc """
  Tests for UUID custom type
  """

  use ShowmakerBackend.DataCase

  # alias __MODULE__.TestModel
  alias ShowmakerBackend.Support.Types.UUID

  @uuid "018df24d-681d-7f49-a9ec-d571c84537ac"
  @raw <<1, 141, 242, 77, 104, 29, 127, 73, 169, 236, 213, 113, 200, 69, 55, 172>>

  describe "cast/2" do
    test "given right values, it must correctly parse into string" do
      assert {:ok, @uuid} == UUID.cast(@raw, %{prefix: "test"})
      assert {:ok, @uuid} == UUID.cast(@raw, %{prefix: nil})
      assert {:ok, @uuid} == UUID.cast(@raw, nil)
    end

    test "given bad values, it must error" do
      assert :error == UUID.cast(nil, nil)
      assert :error == UUID.cast(1, nil)
      assert :error == UUID.cast(%{}, nil)
      assert :error == UUID.cast({}, nil)
      assert :error == UUID.cast([], nil)
    end
  end

  describe "cast!/2" do
    test "given right values, it must correctly parse into string" do
      assert {:ok, @uuid} == UUID.cast(@raw, %{prefix: "test"})
      assert {:ok, @uuid} == UUID.cast(@raw, %{prefix: nil})
      assert {:ok, @uuid} == UUID.cast(@raw, nil)
    end

    test "given bad values, it must error" do
      assert_raise Ecto.CastError, fn -> UUID.cast!(nil, nil) end
      assert_raise Ecto.CastError, fn -> UUID.cast!(1, nil) end
      assert_raise Ecto.CastError, fn -> UUID.cast!(%{}, nil) end
      assert_raise Ecto.CastError, fn -> UUID.cast!({}, nil) end
      assert_raise Ecto.CastError, fn -> UUID.cast!([], nil) end
    end
  end

  describe "load/3" do
    test "given right values, it must correctly parse into string" do
      assert {:ok, "test_#{@uuid}"} == UUID.load(@raw, nil, %{prefix: "test"})
      assert {:ok, @uuid} == UUID.load(@raw, nil, %{prefix: nil})
      assert {:ok, @uuid} == UUID.load(@raw, nil, nil)
    end

    test "given bad values, it must error" do
      assert :error == UUID.load(nil, nil, nil)
      assert :error == UUID.load(1, nil, nil)
      assert :error == UUID.load(%{}, nil, nil)
      assert :error == UUID.load({}, nil, nil)
      assert :error == UUID.load([], nil, nil)
    end
  end

  describe "dump/3" do
    test "given right values, it must correctly parse into binary" do
      assert {:ok, @raw} == UUID.dump(@uuid, nil, %{prefix: "test"})
      assert {:ok, @raw} == UUID.dump(@uuid, nil, %{prefix: nil})
      assert {:ok, @raw} == UUID.dump(@uuid, nil, nil)
      assert {:ok, nil} == UUID.dump(nil, nil, nil)
    end

    test "given bad values, it must error" do
      assert :error == UUID.dump(1, nil, nil)
      assert :error == UUID.dump(%{}, nil, nil)
      assert :error == UUID.dump({}, nil, nil)
      assert :error == UUID.dump([], nil, nil)
    end
  end

  describe "autogenerate/1" do
    test "given no prefix, it must create a regular UUID v7" do
      assert {:ok, uuid} = UUID.autogenerate()
      assert String.length(uuid) == 36
      assert [_one, _two, _three, _four, _five] = String.split(uuid, "-")
    end

    test "given an invalid prefix, it must create a regular UUID v7" do
      assert {:ok, uuid} = UUID.autogenerate("test")
      assert String.length(uuid) == 36

      assert {:ok, uuid} = UUID.autogenerate(1)
      assert String.length(uuid) == 36

      assert {:ok, uuid} = UUID.autogenerate(nil)
      assert String.length(uuid) == 36
    end

    test "given a valid prefix, it must create a prefixed UUID v7" do
      assert {:ok, uuid} = UUID.autogenerate(%{prefix: "test"})
      assert String.length(uuid) == 41
      assert ["test", uuid] = String.split(uuid, "_")
      assert [_one, _two, _three, _four, _five] = String.split(uuid, "-")
    end
  end

  # defmodule __MODULE__.TestModel do
  #   @moduledoc false

  #   use Ecto.Schema

  #   alias Ecto.Changeset

  #   @primary_key {:id, UUID, prefix: "test", autogenerate: true}
  #   embedded_schema do
  #     field :random, :integer
  #   end

  #   def new(struct \\ %__MODULE__{}, params) do
  #     struct
  #     |> Changeset.cast(params, [:random])
  #     |> Changeset.apply_action(:insert)
  #   end
  # end
end
