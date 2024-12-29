defmodule SwaddledWeb.ImportLive.IndexTest do
  use SwaddledWeb.ConnCase

  import Phoenix.LiveViewTest
  import Swaddled.ImporterFixtures

  describe "dashboard index" do
    test "successfully uploads and imports a zip file", %{conn: conn} do
      # We should redirect to `/import` when there are no listens
      assert {:ok, index_live, html} = live(conn, ~p"/import")
      assert html =~ "Import Your Streaming History"

      name = "my_spotify_data.zip"

      history =
        file_input(index_live, "#upload-form", :streaming_history, [
          %{
            name: name,
            content: File.read!(zip_file_path()),
            size: 1_471_872,
            type: "application/zip"
          }
        ])

      assert render_upload(history, name) =~ "Loading data..."
      assert render_async(index_live) =~ "Imported 14 listens."
    end
  end
end
