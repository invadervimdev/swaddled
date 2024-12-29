defmodule Swaddled.ListensFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Swaddled.Listens` context.
  """

  @doc """
  Generate a listen.
  """
  def listen_fixture(attrs \\ %{}) do
    {:ok, listen} =
      attrs
      |> Enum.into(%{
        ms_played: 42,
        started_at: ~U[2024-12-28 04:13:00Z]
      })
      |> Swaddled.Listens.create()

    listen
  end
end
