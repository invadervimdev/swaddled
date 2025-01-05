defmodule SwaddledWeb.DashboardLive.IndexTest do
  use SwaddledWeb.ConnCase

  import Phoenix.LiveViewTest
  import Swaddled.ImporterFixtures

  describe "dashboard index" do
    test "redirects when there are no listens", %{conn: conn} do
      # We should redirect to `/import` when there are no listens
      assert {:error, {:live_redirect, %{to: "/import"}}} = live(conn, ~p"/")
    end

    test "shows the dashboard", %{conn: conn} do
      assert {:ok, _} = seed_data()
      assert {:ok, index_live, html} = live(conn, ~p"/")
      assert html =~ "This year, you listened to 14 songs for a total of 19 minutes!"
      assert html =~ "Top Artists"

      # Testing controls
      assert index_live
             |> element("#top-carousel-next")
             |> render_click() =~ "Top Tracks"

      # Testing indicators
      assert index_live
             |> element("#top-carousel-indicator-2")
             |> render_click() =~ "Top Genres"

      # Testing play/pause
      assert index_live
             |> element("#top-carousel-indicator-2.bg-green-400")
             |> has_element?()

      refute index_live
             |> element("#top-carousel-indicator-0.bg-green-400")
             |> has_element?()

      :timer.sleep(10)

      assert index_live
             |> element("#top-carousel-indicator-0.bg-green-400")
             |> has_element?()
    end
  end
end
