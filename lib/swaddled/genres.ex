defmodule Swaddled.Genres do
  @moduledoc """
  Genres are poorly designed in Spotify. Instead of being associated to a track,
  the genres are just an array on the artist. Since there's not an easy way to
  easily identify which tracks are which genres, this simply links all genres to
  a listen.
  """

  import Ecto.Query, warn: false
  alias Swaddled.Repo

  alias Swaddled.Genres.Genre

  @doc """
  Returns the list of genres.

  ## Examples

      iex> list()
      [%Genre{}, ...]

  """
  def list do
    Repo.all(Genre)
  end

  @doc """
  Gets a single genre.

  Raises `Ecto.NoResultsError` if the Genre does not exist.

  ## Examples

      iex> get!(123)
      %Genre{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(Genre, id)

  @doc """
  Creates a genre.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Genre{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    %Genre{}
    |> Genre.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a genre.

  ## Examples

      iex> update(genre, %{field: new_value})
      {:ok, %Genre{}}

      iex> update(genre, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Genre{} = genre, attrs) do
    genre
    |> Genre.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a genre.

  ## Examples

      iex> delete(genre)
      {:ok, %Genre{}}

      iex> delete(genre)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Genre{} = genre) do
    Repo.delete(genre)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking genre changes.

  ## Examples

      iex> change(genre)
      %Ecto.Changeset{data: %Genre{}}

  """
  def change(%Genre{} = genre, attrs \\ %{}) do
    Genre.changeset(genre, attrs)
  end

  @doc """
  Shows the top 5 genres by total listening time.
  """
  @spec top(non_neg_integer(), atom()) :: list(%{name: String.t(), ms: non_neg_integer()})
  def top(year, type) do
    from(l in Swaddled.Listens.by_year(year, type),
      join: g in assoc(l, :genres),
      group_by: g.name,
      select_merge: %{name: g.name}
    )
    |> Repo.all()
  end
end
