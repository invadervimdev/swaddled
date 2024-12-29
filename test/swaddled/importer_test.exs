defmodule Swaddled.ImporterTest do
  use Swaddled.DataCase

  import Swaddled.ImporterFixtures

  alias Swaddled.Importer

  setup_all do
    %{zip_file: zip_file()}
  end

  describe "load/1" do
    test "successfully loads data", %{zip_file: file} do
      assert {:ok, listens_count} = Importer.load(file)
      assert Swaddled.Artists.list() |> Enum.count() == 6
      assert Swaddled.Tracks.list() |> Enum.count() == 13
      assert Swaddled.Listens.list() |> Enum.count() == listens_count
    end
  end

  describe "upload/1" do
    test "successfully uploads data", %{zip_file: file} do
      assert {:ok, %{listens: listens_count}} = Importer.upload(file)
      assert Swaddled.Listens.list() |> Enum.count() == listens_count
    end
  end
end
