defmodule Swaddled.TracksFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Swaddled.Tracks` context.
  """

  @doc """
  Generate a track.
  """
  def track_fixture(attrs \\ %{}) do
    {:ok, track} =
      attrs
      |> Enum.into(%{
        name: "some name",
        spotify_id: Ecto.UUID.generate()
      })
      |> Swaddled.Tracks.create()

    track
  end
end
