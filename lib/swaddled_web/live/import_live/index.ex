defmodule SwaddledWeb.ImportLive.Index do
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
     |> assign(:show_form, true)
     |> assign(:uploaded_files, [])
     |> allow_upload(:streaming_history,
       accept: ~w(.zip),
       auto_upload: true,
       max_entries: 1,
       max_file_size: 20_000_000,
       progress: &handle_progress/3
     )}
  end

  @impl Phoenix.LiveView
  def handle_event("validate", _params, socket) do
    {:noreply, socket}
  end

  defp handle_progress(:streaming_history, entry, socket) do
    if entry.done? do
      {:noreply,
       consume_uploaded_entry(socket, entry, fn %{path: path} ->
         file = File.read!(path)

         {:ok,
          socket
          |> assign(:show_form, false)
          |> assign_async(:listens, fn -> Swaddled.Importer.upload(file) end)}
       end)}
    else
      {:noreply, socket}
    end
  end

  defp error_to_string(:too_large), do: "Too large"
  defp error_to_string(:too_many_files), do: "You have selected too many files"
  defp error_to_string(:not_accepted), do: "You have selected an unacceptable file type"
end
