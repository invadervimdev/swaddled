defmodule Swaddled.Listens do
  @moduledoc """
  Represents when the user played back a track.
  """

  import Ecto.Query, warn: false
  alias Swaddled.Repo

  alias Swaddled.Listens.Listen

  @doc """
  Returns the list of listens.

  ## Examples

      iex> list()
      [%Listen{}, ...]

  """
  def list do
    Repo.all(Listen)
  end

  @doc """
  Gets a single listen.

  Raises `Ecto.NoResultsError` if the Listen does not exist.

  ## Examples

      iex> get!(123)
      %Listen{}

      iex> get!(456)
      ** (Ecto.NoResultsError)

  """
  def get!(id), do: Repo.get!(Listen, id)

  @doc """
  Creates a listen.

  ## Examples

      iex> create(%{field: value})
      {:ok, %Listen{}}

      iex> create(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create(attrs \\ %{}) do
    %Listen{}
    |> Listen.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a listen.

  ## Examples

      iex> update(listen, %{field: new_value})
      {:ok, %Listen{}}

      iex> update(listen, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update(%Listen{} = listen, attrs) do
    listen
    |> Listen.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a listen.

  ## Examples

      iex> delete(listen)
      {:ok, %Listen{}}

      iex> delete(listen)
      {:error, %Ecto.Changeset{}}

  """
  def delete(%Listen{} = listen) do
    Repo.delete(listen)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking listen changes.

  ## Examples

      iex> change(listen)
      %Ecto.Changeset{data: %Listen{}}

  """
  def change(%Listen{} = listen, attrs \\ %{}) do
    Listen.changeset(listen, attrs)
  end

  @doc """
  Total time listening to music in given year (in ms).
  """
  @spec total_played(non_neg_integer()) :: non_neg_integer()
  def total_played(year) do
    import Ecto.Query

    start_date = to_datetime(year)
    end_date = to_datetime(year + 1)

    query =
      from l in Listen,
        where: l.started_at >= ^start_date,
        where: l.started_at < ^end_date,
        select: sum(l.ms_played)

    [ms] = Repo.all(query)
    ms
  end

  defp to_datetime(year), do: year |> Date.new!(1, 1) |> DateTime.new!(~T[00:00:00])

  @doc """
  Returns a list of years in which a listen was recorded. Note all dates are in
  UTC.
  """
  @spec years() :: list(integer())
  def years do
    query =
      from l in Listen,
        select: fragment("date_part('year', started_at)::INT"),
        distinct: true,
        order_by: [desc: fragment("date_part('year', started_at)::INT")]

    Repo.all(query)
  end
end
