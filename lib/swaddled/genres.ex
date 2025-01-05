defmodule Swaddled.Genres do
  @moduledoc """
  Genres are poorly designed in Spotify. Instead of being associated to a track,
  the genres are just an array on the artist. Since there's not an easy way to
  easily identify which tracks are which genres, this app simply links all of
  the artist's genres to their tracks. Here's an example:

  Artist A has the genres "rock" and "pop" and two tracks that are 5 minutes
  each. If we count each song has been listened to once, then we'd have the
  following stats:

  Total play count: 2
  Total time played: 10 minutes
  Total "rock" play count: 2
  Total "rock" time played: 10 minutes
  Total "pop" plays: 2
  Total "pop" time played: 10 minutes

  As you can see, this inflates the numbers for the genres metrics immensely,
  especially with the most generic genres like "pop" and "rock". Artists may
  have this genre along with a subgenre (e.g. "rock" and "pop rock"), as well,
  inflating the number even more.

  In a future update, it'd be nice to get the genre data from another source,
  but then we'll need to link the Spotify track to the new source somehow.
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
