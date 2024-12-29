defmodule Swaddled.ArtistsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Swaddled.Artists` context.
  """

  @doc """
  Generate a artist.
  """
  def artist_fixture(attrs \\ %{}) do
    {:ok, artist} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Swaddled.Artists.create()

    artist
  end
end
