defmodule Swaddled.ArtistsTest do
  use Swaddled.DataCase

  alias Swaddled.Artists

  describe "artists" do
    alias Swaddled.Artists.Artist

    import Swaddled.ArtistsFixtures

    @invalid_attrs %{name: nil}

    test "list/0 returns all artists" do
      artist = artist_fixture() |> Map.put(:genres, [])
      assert Artists.list() == [artist]
    end

    test "get!/1 returns the artist with given id" do
      artist = artist_fixture()
      assert Artists.get!(artist.id) == artist
    end

    test "create/1 with valid data creates a artist" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Artist{} = artist} = Artists.create(valid_attrs)
      assert artist.name == "some name"
    end

    test "create/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Artists.create(@invalid_attrs)
    end

    test "update/2 with valid data updates the artist" do
      artist = artist_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Artist{} = artist} = Artists.update(artist, update_attrs)
      assert artist.name == "some updated name"
    end

    test "update/2 with invalid data returns error changeset" do
      artist = artist_fixture()
      assert {:error, %Ecto.Changeset{}} = Artists.update(artist, @invalid_attrs)
      assert artist == Artists.get!(artist.id)
    end

    test "delete/1 deletes the artist" do
      artist = artist_fixture()
      assert {:ok, %Artist{}} = Artists.delete(artist)
      assert_raise Ecto.NoResultsError, fn -> Artists.get!(artist.id) end
    end

    test "change/1 returns a artist changeset" do
      artist = artist_fixture()
      assert %Ecto.Changeset{} = Artists.change(artist)
    end
  end
end
