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

  alias Swaddled.Repo
  alias Swaddled.Artists.Artist
  alias Swaddled.Listens.Listen
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
          spotify_uri: &1["spotify_track_uri"]
        ]
      )
      |> Enum.uniq()

    Track
    |> Repo.insert_all(attrs,
      returning: [:id, :artist_id, :name, :spotify_uri],
      on_conflict: {:replace, [:artist_id, :name, :spotify_uri]},
      conflict_target: [:artist_id, :name, :spotify_uri]
    )
    |> elem(1)
    |> Map.new(fn track ->
      {{track.spotify_uri, track.name,
        Enum.find_value(artists, fn {name, id} -> if(id == track.artist_id, do: name) end)},
       %{artist_id: track.artist_id, track_id: track.id}}
    end)
  end

  defp insert_listens(data, tracks) do
    track = fn item ->
      tracks[
        {item["spotify_track_uri"], item["master_metadata_track_name"],
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
end
