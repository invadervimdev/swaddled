defmodule SwaddledWeb.DashboardLive.Index do
  use SwaddledWeb, :live_view

  import SwaddledWeb.CarouselCardComponent

  alias Swaddled.Artists
  alias Swaddled.Listens
  alias Swaddled.Listens.Listen
  alias Swaddled.Repo
  alias Swaddled.Tracks

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  @spec handle_params(any(), any(), any()) :: {:noreply, any()}
  def handle_params(_params, _url, socket) do
    if Repo.exists?(Listen) do
      years = Listens.years()

      {:noreply,
       socket
       |> assign(:active_card, 0)
       |> assign(:year, hd(years))
       |> assign(:years, years)
       |> assign(:show_years_dropdown, false)
       |> update_metrics()}
    else
      {:noreply, push_patch(socket, to: "/import")}
    end
  end

  @impl true
  def handle_event("change-year", %{"year" => year}, socket) do
    {year, _} = Integer.parse(year)

    {:noreply,
     socket
     |> assign(:year, year)
     |> assign(:show_years_dropdown, false)
     |> update_metrics()}
  end

  @impl true
  def handle_event("toggle-years-dropdown", _, socket) do
    {:noreply, assign(socket, :show_years_dropdown, !socket.assigns.show_years_dropdown)}
  end

  @impl true
  def handle_info({:active_card, id}, socket) do
    {:noreply, assign(socket, :active_card, id)}
  end

  defp update_metrics(%{assigns: %{year: year}} = socket) do
    socket
    |> assign(:top_artists, Artists.top(year))
    |> assign(:top_tracks, Tracks.top(year))
  end

  defp minutes(ms), do: "#{round(ms / 60_000)} min"
end
