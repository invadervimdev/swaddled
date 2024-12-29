defmodule Swaddled.ImporterFixtures do
  @moduledoc """
  Not really a fixture, just an easy way to seed data for tests.
  """

  alias Swaddled.Importer

  @doc """
  Loads artist, tracks, and listens data.
  """
  def seed_data, do: Importer.upload(zip_file())

  @doc """
  Allows the path to be grabbed from tests.
  """
  def zip_file_path, do: "test/support/files/my_spotify_data.zip"

  def zip_file, do: File.read!(zip_file_path())
end
