defmodule Swaddled.Tracks do
  @moduledoc """
  Represents a song.

  NOTE: uri's are NOT unique.
  """

  import Ecto.Query, warn: false
  alias Swaddled.Repo

  alias Swaddled.Tracks.Track

  @doc """
  Returns the list of tracks.

  ## Examples

      iex> list()
      [%Track{}, ...]

  """
  def list do
    Repo.all(Track)
  end

  @doc """
  Gets a single track.

  Raises `Ecto.NoResultsError` if the Track does not exist.

  ## Examples

      iex> get!(123)
      %Track{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(Track, id)

  @doc """
  Creates a track.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Track{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    %Track{}
    |> Track.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a track.

  ## Examples

      iex> update(track, %{field: new_value})
      {:ok, %Track{}}

      iex> update(track, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Track{} = track, attrs) do
    track
    |> Track.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a track.

  ## Examples

      iex> delete(track)
      {:ok, %Track{}}

      iex> delete(track)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Track{} = track) do
    Repo.delete(track)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking track changes.

  ## Examples

      iex> change(track)
      %Ecto.Changeset{data: %Track{}}

  """
  def change(%Track{} = track, attrs \\ %{}) do
    Track.changeset(track, attrs)
  end

  @doc """
  Shows the top 5 tracks by total listening time.
  """
  @spec top(non_neg_integer(), atom()) :: list(%Track{})
  def top(year, type) do
    from(l in Swaddled.Listens.by_year(year, type),
      join: a in assoc(l, :artist),
      join: t in assoc(l, :track),
      group_by: [t.name, a.name],
      select_merge: %{artist: a.name, name: t.name}
    )
    |> Repo.all()
  end
end
