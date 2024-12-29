defmodule SwaddledWeb.DashboardLive.Index do
  use SwaddledWeb, :live_view

  import SwaddledWeb.CarouselCardComponent

  alias Swaddled.Artists
  alias Swaddled.Listens.Listen
  alias Swaddled.Repo
  alias Swaddled.Tracks

  @impl true
  def mount(_params, _session, socket) do
    {:ok, assign(socket, :year, Date.utc_today().year)}
  end

  @impl true
  @spec handle_params(any(), any(), any()) :: {:noreply, any()}
  def handle_params(_params, _url, socket) do
    if Repo.exists?(Listen) do
      {:noreply,
       socket
       |> assign(:active_card, 0)
       |> assign(:top_artists, Artists.top(socket.assigns.year))
       |> assign(:top_tracks, Tracks.top(socket.assigns.year))}
    else
      {:noreply, push_patch(socket, to: "/import")}
    end
  end

  @impl true
  def handle_info({:active_card, id}, socket) do
    {:noreply, assign(socket, :active_card, id)}
  end

  defp minutes(ms), do: "#{round(ms / 60_000)} min"
end
