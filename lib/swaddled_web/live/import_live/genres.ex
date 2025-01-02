defmodule SwaddledWeb.ImportLive.Genres do
  @moduledoc """
  Uploads the file and feeds it directly to the Importer. Since a file can be
  pretty big (my 12MB personal Spotify zip file expands to 126MB), we want to
  show a loader while the Importer process works in the background.
  """

  use SwaddledWeb, :live_view

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    {:ok,
     socket
     |> assign(:show_credentials_form, missing_credentials?())
     |> assign(:form_error, "")
     |> assign(:import_error, "")
     |> assign(:genres_imported, 0)}
  end

  defp missing_credentials? do
    !System.get_env("SPOTIFY_CLIENT_ID") or !System.get_env("SPOTIFY_CLIENT_SECRET")
  end

  @impl Phoenix.LiveView
  def handle_event("start", _params, socket) do
    if missing_credentials?() do
      {:noreply, assign(socket, :import_error, "Set your Spotify credentials first!")}
    else
      :ok = Phoenix.PubSub.subscribe(Swaddled.PubSub, topic())

      {:noreply,
       socket
       |> assign(:preimport_total, Swaddled.Repo.aggregate(Swaddled.Genres.Genre, :count))
       |> assign_async(:total_genres, fn -> Swaddled.Importer.load_genres(0) end)}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("save", %{"credentials" => params}, socket) do
    if params["client_id"] == "" or params["client_secret"] == "" do
      {:noreply, assign(socket, :form_error, "Must provide both client ID and client secret")}
    else
      :ok = System.put_env("SPOTIFY_CLIENT_ID", params["client_id"])
      :ok = System.put_env("SPOTIFY_CLIENT_SECRET", params["client_secret"])
      {:noreply, assign(socket, :show_credentials_form, false)}
    end
  end

  @impl Phoenix.LiveView
  def handle_event("toggle-credentials-form", _params, socket) do
    {:noreply, assign(socket, :show_credentials_form, !socket.assigns.show_credentials_form)}
  end

  @impl Phoenix.LiveView
  def handle_info({:import_genres, count}, socket) do
    {:noreply, assign(socket, :genres_imported, count - socket.assigns.preimport_total)}
  end

  def topic, do: "import_genres"
end
