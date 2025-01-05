defmodule Swaddled.Listens do
  @moduledoc """
  Represents when the user played a track.

  There are two things to note that skew the listening time:

  1. This app does not use time zones, so all your data will be as if you live
     in London (if you listened to all your music in London, perfect!).

  2. Your time listened only counts for the day the track started playing. For
     example, if the track is 1 hour long and was started on December 31, 2024
     at 11:59pm, the full hour will be considered listened to in 2024.

     One could make a case that only 1 minute should count towards 2024 and the
     rest of the time should be counted in 2025, but I didn't think the work was
     worth it for this initial phase.
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
  Total songs played in given year.
  """
  @spec total_play_count(non_neg_integer()) :: non_neg_integer()
  def total_play_count(year) do
    [%{count: count}] = by_year(year) |> Repo.all()
    count
  end

  @doc """
  Total time listening to music in given year (in ms).
  """
  @spec total_time_played(non_neg_integer()) :: non_neg_integer()
  def total_time_played(year) do
    [%{ms: ms}] = by_year(year) |> Repo.all()
    ms
  end

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

  @doc """
  Helper function that returns a query to get all listens for a year.
  """
  @spec by_year(non_neg_integer(), atom()) :: any()
  def by_year(year, type \\ :time) do
    import Ecto.Query

    start_date = to_datetime(year)
    end_date = to_datetime(year + 1)

    order_by =
      case type do
        :count -> dynamic([l], count(l.id))
        :time -> dynamic([l], sum(l.ms_played))
      end

    from l in Listen,
      select: %{count: count(l.id), ms: sum(l.ms_played)},
      where: l.started_at >= ^start_date,
      where: l.started_at < ^end_date,
      order_by: ^[desc: order_by],
      limit: 5
  end

  defp to_datetime(year), do: year |> Date.new!(1, 1) |> DateTime.new!(~T[00:00:00])
end
