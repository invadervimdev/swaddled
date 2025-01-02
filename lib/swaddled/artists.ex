defmodule Swaddled.Artists do
  @moduledoc """
  An artist is the creator or performer of a track. Each track is linked to only
  one artist, so even though a song may be a duet, the data shows it's only tied
  to one artist.
  """

  import Ecto.Query, warn: false
  alias Swaddled.Repo

  alias Swaddled.Artists.Artist

  @doc """
  Returns the list of artists.

  ## Examples

      iex> list()
      [%Artist{}, ...]

  """
  def list do
    Artist
    |> preload(:genres)
    |> Repo.all()
  end

  @doc """
  Gets a single artist.

  Raises `Ecto.NoResultsError` if the Artist does not exist.

  ## Examples

      iex> get!(123)
      %Artist{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(Artist, id)

  @doc """
  Creates a artist.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Artist{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    %Artist{}
    |> Artist.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a artist.

  ## Examples

      iex> update(artist, %{field: new_value})
      {:ok, %Artist{}}

      iex> update(artist, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Artist{} = artist, attrs) do
    artist
    |> Artist.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a artist.

  ## Examples

      iex> delete(artist)
      {:ok, %Artist{}}

      iex> delete(artist)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Artist{} = artist) do
    Repo.delete(artist)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking artist changes.

  ## Examples

      iex> change(artist)
      %Ecto.Changeset{data: %Artist{}}

  """
  def change(%Artist{} = artist, attrs \\ %{}) do
    Artist.changeset(artist, attrs)
  end

  @doc """
  Shows the top 5 artists by total listening time.
  """
  @spec top(non_neg_integer()) :: list(%Artist{})
  def top(year) do
    query =
      from l in Swaddled.Listens.by_year(year),
        join: a in assoc(l, :artist),
        group_by: a.name,
        order_by: [desc: sum(l.ms_played)],
        select: %{name: a.name, ms: sum(l.ms_played)},
        limit: 5

    Repo.all(query)
  end

  @doc """
  Specfiically used to grab artists/tracks to feed into the Spotify Web API.
  The relevant endpoints only allows 50 ids at a time, which is why the limit is
  set.
  """
  @spec with_track_ids(non_neg_integer()) :: list({%Artist{}, String.t()})
  def with_track_ids(offset) do
    from(a in Artist,
      join: t in assoc(a, :tracks),
      select: {a, max(t.spotify_id)},
      group_by: [a.id],
      preload: [:genres],
      order_by: [:id],
      limit: 50,
      offset: ^(offset * 50)
    )
    |> Repo.all()
  end
end
