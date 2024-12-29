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
end
