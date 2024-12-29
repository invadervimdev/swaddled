defmodule Swaddled.ListensTest do
  use Swaddled.DataCase

  alias Swaddled.Listens

  describe "listens" do
    alias Swaddled.Listens.Listen

    import Swaddled.ListensFixtures

    @invalid_attrs %{started_at: nil, ms_played: nil}

    test "list/0 returns all listens" do
      listen = listen_fixture()
      assert Listens.list() == [listen]
    end

    test "get!/1 returns the listen with given id" do
      listen = listen_fixture()
      assert Listens.get!(listen.id) == listen
    end

    test "create/1 with valid data creates a listen" do
      valid_attrs = %{started_at: ~U[2024-12-28 04:13:00Z], ms_played: 42}

      assert {:ok, %Listen{} = listen} = Listens.create(valid_attrs)
      assert listen.started_at == ~U[2024-12-28 04:13:00Z]
      assert listen.ms_played == 42
    end

    test "create/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Listens.create(@invalid_attrs)
    end

    test "update/2 with valid data updates the listen" do
      listen = listen_fixture()
      update_attrs = %{started_at: ~U[2024-12-29 04:13:00Z], ms_played: 43}

      assert {:ok, %Listen{} = listen} = Listens.update(listen, update_attrs)
      assert listen.started_at == ~U[2024-12-29 04:13:00Z]
      assert listen.ms_played == 43
    end

    test "update/2 with invalid data returns error changeset" do
      listen = listen_fixture()
      assert {:error, %Ecto.Changeset{}} = Listens.update(listen, @invalid_attrs)
      assert listen == Listens.get!(listen.id)
    end

    test "delete/1 deletes the listen" do
      listen = listen_fixture()
      assert {:ok, %Listen{}} = Listens.delete(listen)
      assert_raise Ecto.NoResultsError, fn -> Listens.get!(listen.id) end
    end

    test "change/1 returns a listen changeset" do
      listen = listen_fixture()
      assert %Ecto.Changeset{} = Listens.change(listen)
    end
  end
end
