defmodule Swaddled.GenresTest do
  use Swaddled.DataCase

  alias Swaddled.Genres

  describe "genres" do
    alias Swaddled.Genres.Genre

    import Swaddled.GenresFixtures

    @invalid_attrs %{name: nil}

    test "list/0 returns all genres" do
      genre = genre_fixture()
      assert Genres.list() == [genre]
    end

    test "get!/1 returns the genre with given id" do
      genre = genre_fixture()
      assert Genres.get!(genre.id) == genre
    end

    test "create/1 with valid data creates a genre" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %Genre{} = genre} = Genres.create(valid_attrs)
      assert genre.name == "some name"
    end

    test "create/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Genres.create(@invalid_attrs)
    end

    test "update/2 with valid data updates the genre" do
      genre = genre_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %Genre{} = genre} = Genres.update(genre, update_attrs)
      assert genre.name == "some updated name"
    end

    test "update/2 with invalid data returns error changeset" do
      genre = genre_fixture()
      assert {:error, %Ecto.Changeset{}} = Genres.update(genre, @invalid_attrs)
      assert genre == Genres.get!(genre.id)
    end

    test "delete/1 deletes the genre" do
      genre = genre_fixture()
      assert {:ok, %Genre{}} = Genres.delete(genre)
      assert_raise Ecto.NoResultsError, fn -> Genres.get!(genre.id) end
    end

    test "change/1 returns a genre changeset" do
      genre = genre_fixture()
      assert %Ecto.Changeset{} = Genres.change(genre)
    end
  end
end
