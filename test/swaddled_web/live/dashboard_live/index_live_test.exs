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
      assert {:ok, _index_live, html} = live(conn, ~p"/")
      assert html =~ "Total time played: 19 min"
      assert html =~ "Nora En Pure (12 min)"
    end
  end
end
