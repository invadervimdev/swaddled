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
    Repo.all(Artist)
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
end
