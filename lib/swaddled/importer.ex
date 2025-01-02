defmodule Swaddled.Importer do
  @moduledoc """
  Takes a Spotify zip file (`my_spotify_data.zip`) and inserts the data into the
  database.

  ## Instructions

  1. Log into Spotify on web browser.
  2. Scroll down to "Security and privacy" section.
  3. Click "Account privacy".
  4. Download "Extended streaming history"

  You'll eventually (in a few days) get a link to download a zip file.
  """

  alias Ecto.Multi
  alias Swaddled.Artists
  alias Swaddled.Artists.Artist
  alias Swaddled.Genres.Genre
  alias Swaddled.Listens.Listen
  alias Swaddled.Repo
  alias Swaddled.Tracks.Track

  @doc """
  In the name of speed, I wanted to try to use `insert_all` in as many places as
  possible. This is why I group all the artists, their tracks, and then the list
  of listens.
  """
  @spec load(binary()) :: {:ok, non_neg_integer()}
  def load(zip_file) do
    {:ok, handle} = :zip.zip_open(zip_file, [:memory])

    try do
      handle
      |> get_audio_filenames()
      |> process_files(handle, 0)
    after
      :zip.zip_close(handle)
    end
  end

  @doc """
  Used by LiveView to load a file. This expects a file path.
  """
  @spec upload(binary()) :: {:ok, %{total_listens: non_neg_integer()}}
  def upload(file) do
    file
    |> load()
    |> case do
      {:ok, count} -> {:ok, %{total_listens: count}}
    end
  end

  defp get_audio_filenames(handle) do
    {:ok, files} = :zip.zip_list_dir(handle)

    Enum.reduce(files, [], fn
      {:zip_file, filename, _, _, _, _}, acc ->
        # Only grab the audio json files (ignores video history)
        if String.match?("#{filename}", ~r/.*Audio.*\.json$/) do
          [filename | acc]
        else
          acc
        end

      _, acc ->
        acc
    end)
  end

  defp process_files([], _handle, listens_imported), do: {:ok, listens_imported}

  defp process_files([filename | filenames], handle, total_listens_imported) do
    {:ok, {_name, json}} = :zip.zip_get(filename, handle)

    # Remove podcast episodes
    data =
      json
      |> Jason.decode!()
      |> Enum.filter(& &1["spotify_track_uri"])

    artists = insert_artists(data)
    tracks = insert_tracks(data, artists)
    new_listens_imported = insert_listens(data, tracks)

    broadcast(SwaddledWeb.ImportLive.Index.topic(), {:import_listens, new_listens_imported})
    process_files(filenames, handle, total_listens_imported + new_listens_imported)
  end

  defp insert_artists(data) do
    attrs =
      data
      |> Enum.map(&[name: &1["master_metadata_album_artist_name"]])
      |> Enum.uniq()

    Artist
    |> Repo.insert_all(attrs,
      returning: [:id, :name],
      on_conflict: {:replace, [:name]},
      conflict_target: [:name]
    )
    |> elem(1)
    |> Map.new(fn artist -> {artist.name, artist.id} end)
  end

  defp insert_tracks(data, artists) do
    attrs =
      data
      |> Enum.map(
        &[
          artist_id: artists[&1["master_metadata_album_artist_name"]],
          name: &1["master_metadata_track_name"],
          spotify_id: &1["spotify_track_uri"] |> String.split(":") |> List.last()
        ]
      )
      |> Enum.uniq()

    Track
    |> Repo.insert_all(attrs,
      returning: [:id, :artist_id, :name, :spotify_id],
      on_conflict: {:replace, [:artist_id, :name, :spotify_id]},
      conflict_target: [:artist_id, :name, :spotify_id]
    )
    |> elem(1)
    |> Map.new(fn track ->
      {{track.spotify_id, track.name,
        Enum.find_value(artists, fn {name, id} -> if(id == track.artist_id, do: name) end)},
       %{artist_id: track.artist_id, track_id: track.id}}
    end)
  end

  defp insert_listens(data, tracks) do
    track = fn item ->
      spotify_id = item["spotify_track_uri"] |> String.split(":") |> List.last()

      tracks[
        {spotify_id, item["master_metadata_track_name"],
         item["master_metadata_album_artist_name"]}
      ]
    end

    data
    |> Enum.map(
      &[
        artist_id: track.(&1).artist_id,
        ms_played: &1["ms_played"],
        started_at: &1["ts"] |> DateTime.from_iso8601() |> elem(1),
        track_id: track.(&1).track_id
      ]
    )
    |> Enum.uniq()
    |> Enum.chunk_every(10_000)
    |> Enum.map(fn attrs ->
      Listen
      |> Repo.insert_all(attrs,
        on_conflict: {:replace, [:artist_id, :track_id, :started_at, :ms_played]},
        conflict_target: [:artist_id, :track_id, :started_at, :ms_played]
      )
      |> case do
        {count, nil} -> count
      end
    end)
    |> Enum.sum()
  end

  @doc """
  Genres are not included in the zip data. This calls out to the Spotify Web API
  to import the genres using the track/artist data imported in the zip file.
  See `Swaddled.Vendor.Spotify` for details.

  Enter an offset if there was an error and need to continue from a certain
  point.
  """
  @spec load_genres(non_neg_integer()) :: :ok
  def load_genres(offset \\ 0, genres_count \\ 0) do
    offset
    |> Artists.with_track_ids()
    |> case do
      [] ->
        {:ok, %{total_genres: genres_count}}

      artists ->
        artists
        |> get_spotify_tracks!()
        |> get_spotify_genres!()
        |> queue_create_genres()
        |> queue_artist_updates()
        |> Repo.transaction()
        |> case do
          {:ok, %{genres_count: count}} ->
            broadcast(SwaddledWeb.ImportLive.Genres.topic(), {:import_genres, count})
            load_genres(offset + 1, count)

          err ->
            raise(offset: offset, error: err)
        end
    end
  rescue
    FunctionClauseError ->
      {:error, "bad credentials"}
  end

  defp get_spotify_tracks!(artist_with_tracks) do
    {artists, spotify_track_ids} =
      Enum.reduce(artist_with_tracks, {[], []}, fn {artist, spotify_track_id},
                                                   {artists, spotify_track_ids} ->
        {[artist | artists], [spotify_track_id | spotify_track_ids]}
      end)

    spotify_artist_ids =
      spotify_track_ids
      |> Swaddled.Vendor.Spotify.get_many!("tracks")
      |> then(& &1.body["tracks"])
      |> Enum.map(fn track -> track["artists"] |> List.first() |> Map.get("id") end)

    merge_spotify_ids(artists, spotify_artist_ids, [])
  end

  defp merge_spotify_ids([], [], artists), do: artists

  defp merge_spotify_ids([artist | artists], [spotify_id | spotify_ids], acc) do
    merge_spotify_ids(artists, spotify_ids, [Map.put(artist, :new_spotify_id, spotify_id) | acc])
  end

  defp get_spotify_genres!(artists) do
    spotify_genres =
      artists
      |> Enum.map(& &1.new_spotify_id)
      |> Swaddled.Vendor.Spotify.get_many!("artists")
      |> then(& &1.body["artists"])
      |> Enum.map(& &1["genres"])

    merge_genres(artists, spotify_genres, [])
  end

  defp merge_genres([], [], artists), do: artists

  defp merge_genres([artist | artists], [artist_genres | genres], acc) do
    merge_genres(artists, genres, [Map.put(artist, :new_genres, artist_genres) | acc])
  end

  defp queue_create_genres(artists) do
    import Ecto.Query

    # Not the most efficient way to do this, but we're looking at 50 artists
    # max, so not that big of a deal
    genres =
      artists
      |> Enum.map(& &1.new_genres)
      |> List.flatten()
      |> Enum.uniq()

    Multi.new()
    |> Multi.put(:artists, artists)
    |> Multi.insert_all(
      :genres,
      Genre,
      Enum.map(genres, &%{name: &1}),
      returning: [:id, :name],
      on_conflict: {:replace, [:name]},
      conflict_target: [:name]
    )
    |> Multi.one(:genres_count, select(Genre, fragment("count(id)")))
    |> then(&{&1, artists})
  end

  defp queue_artist_updates({m, artists}) do
    Enum.reduce(artists, m, fn artist, multi ->
      Multi.update(
        multi,
        {:artist, artist.id},
        fn %{genres: {_count, genres}} ->
          {new_genre_names, artist} = Map.pop(artist, :new_genres)
          {new_spotify_id, artist} = Map.pop(artist, :new_spotify_id)

          new_genres =
            Enum.map(new_genre_names, fn name -> Enum.find(genres, &(&1.name == name)) end)

          artist
          |> Swaddled.Artists.change(%{spotify_id: new_spotify_id})
          |> Ecto.Changeset.put_assoc(:genres, new_genres)
        end
      )
    end)
  end

  defp broadcast(topic, msg) do
    Phoenix.PubSub.broadcast(Swaddled.PubSub, topic, msg)
  end
end
