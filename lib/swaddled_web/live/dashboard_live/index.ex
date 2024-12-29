defmodule SwaddledWeb.DashboardLive.Index do
  use SwaddledWeb, :live_view

  alias Swaddled.Repo
  alias Swaddled.Listens.Listen

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  @spec handle_params(any(), any(), any()) :: {:noreply, any()}
  def handle_params(_params, _url, socket) do
    if Repo.exists?(Listen) do
      {:noreply, socket}
    else
      {:noreply, push_patch(socket, to: "/import")}
    end
  end
end
