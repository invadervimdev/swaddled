defmodule Swaddled.GenresFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Swaddled.Genres` context.
  """

  @doc """
  Generate a genre.
  """
  def genre_fixture(attrs \\ %{}) do
    {:ok, genre} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Swaddled.Genres.create()

    genre
  end
end
