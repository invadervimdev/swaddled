defmodule Swaddled.ImporterTest do
  use Swaddled.DataCase

  alias Swaddled.Importer

  @zip_file_path "test/support/files/my_spotify_data.zip"

  describe "importer" do
    test "successfully loads data" do
      file = File.read!(@zip_file_path)

      assert {:ok, 14} == Importer.load(file)

      assert 6 == Swaddled.Artists.list() |> Enum.count()
      assert 13 == Swaddled.Tracks.list() |> Enum.count()
      assert 14 == Swaddled.Listens.list() |> Enum.count()
    end
  end
end
