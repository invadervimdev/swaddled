defmodule SwaddledWeb.ImportLive.GenresTest do
  use SwaddledWeb.ConnCase

  import Phoenix.LiveViewTest
  import Swaddled.ImporterFixtures

  describe "import genres" do
    test "successfully saves liveview", %{conn: conn} do
      refute System.get_env("SPOTIFY_CLIENT_ID")
      assert {:ok, genres_live, html} = live(conn, ~p"/import/genres")
      assert html =~ "Import Genres"
      assert html =~ "Client ID:"

      assert genres_live
             |> form("#credentials-form")
             |> render_submit(%{}) =~
               "Must provide both client ID and client secret"

      refute System.get_env("SPOTIFY_CLIENT_ID")

      refute genres_live
             |> form("#credentials-form")
             |> render_submit(%{
               credentials: %{client_id: "my_client_id", client_secret: "my_client_secret"}
             }) =~ "Client ID:"

      assert System.get_env("SPOTIFY_CLIENT_ID")
    end

    @tag :external
    test "successfully downloads genres", %{conn: conn} do
      # This test quires that the SPOTIFY_CLIENT_ID and SPOTIFY_CLIENT_SECRET
      # env vars are set. If the "CLIENT ID" assertion fails, that means it's
      # not set.
      assert {:ok, genres_live, html} = live(conn, ~p"/import/genres")
      refute html =~ "Client ID:"

      # Need to seed data so we have some artists to download genres for.
      seed_data()

      assert genres_live
             |> element("button", "Start!")
             |> render_click() =~ "Loading 0 genres..."

      assert render_async(genres_live, 1000) =~ "Imported 21 new genres (21 total)."
    end
  end
end
