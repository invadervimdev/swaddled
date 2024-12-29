defmodule Swaddled.TracksTest do
  use Swaddled.DataCase

  alias Swaddled.Tracks

  describe "tracks" do
    alias Swaddled.Tracks.Track

    import Swaddled.TracksFixtures

    @invalid_attrs %{name: nil, spotify_uri: nil}

    test "list/0 returns all tracks" do
      track = track_fixture()
      assert Tracks.list() == [track]
    end

    test "get!/1 returns the track with given id" do
      track = track_fixture()
      assert Tracks.get!(track.id) == track
    end

    test "create/1 with valid data creates a track" do
      valid_attrs = %{name: "some name", spotify_uri: "some spotify_uri"}

      assert {:ok, %Track{} = track} = Tracks.create(valid_attrs)
      assert track.name == "some name"
      assert track.spotify_uri == "some spotify_uri"
    end

    test "create/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Tracks.create(@invalid_attrs)
    end

    test "update/2 with valid data updates the track" do
      track = track_fixture()
      update_attrs = %{name: "some updated name", spotify_uri: "some updated spotify_uri"}

      assert {:ok, %Track{} = track} = Tracks.update(track, update_attrs)
      assert track.name == "some updated name"
      assert track.spotify_uri == "some updated spotify_uri"
    end

    test "update/2 with invalid data returns error changeset" do
      track = track_fixture()
      assert {:error, %Ecto.Changeset{}} = Tracks.update(track, @invalid_attrs)
      assert track == Tracks.get!(track.id)
    end

    test "delete/1 deletes the track" do
      track = track_fixture()
      assert {:ok, %Track{}} = Tracks.delete(track)
      assert_raise Ecto.NoResultsError, fn -> Tracks.get!(track.id) end
    end

    test "change/1 returns a track changeset" do
      track = track_fixture()
      assert %Ecto.Changeset{} = Tracks.change(track)
    end
  end
end
