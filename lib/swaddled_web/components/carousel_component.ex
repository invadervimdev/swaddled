defmodule SwaddledWeb.CarouselComponent do
  @moduledoc """
  This expects the `inner_block` to contain one or more CarouselCard components.
  """
  use SwaddledWeb, :live_component

  @slide_duration 4_000

  @impl true
  @spec mount(map()) :: {:ok, map()}
  def mount(socket) do
    {:ok,
     socket
     |> assign(:active_card, 0)
     |> assign(:auto_slide, true)
     |> start_async(:next_slide, fn -> :timer.sleep(@slide_duration) end)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id}>
      {render_slot(@inner_block)}

      <div class="flex justify-center h-8">
        <div class="flex items-center justify-center gap-3">
          <%= for i <- 0..(@total_cards - 1) do %>
            <div
              class={"w-[30px] h-[3px] cursor-pointer #{indicator_color(@active_card == i)}"}
              phx-click="set-card"
              phx-target={@myself}
              phx-value-card={i}
            />
          <% end %>
        </div>
      </div>

      <div class="flex justify-center">
        <div>
          <a href="#" phx-click="previous" phx-target={@myself}>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="currentColor"
              class="size-6"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="m11.25 9-3 3m0 0 3 3m-3-3h7.5M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
              />
            </svg>
          </a>
        </div>
        <div class="mx-4 cursor-pointer" phx-click="toggle-auto-slide" phx-target={@myself}>
          <svg
            :if={@auto_slide}
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
            class="size-6"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M14.25 9v6m-4.5 0V9M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
            />
          </svg>
          <svg
            :if={!@auto_slide}
            xmlns="http://www.w3.org/2000/svg"
            fill="none"
            viewBox="0 0 24 24"
            stroke-width="1.5"
            stroke="currentColor"
            class="size-6"
          >
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
            />
            <path
              stroke-linecap="round"
              stroke-linejoin="round"
              d="M15.91 11.672a.375.375 0 0 1 0 .656l-5.603 3.113a.375.375 0 0 1-.557-.328V8.887c0-.286.307-.466.557-.327l5.603 3.112Z"
            />
          </svg>
        </div>
        <div>
          <a href="#" class="float-right" phx-click="next" phx-target={@myself}>
            <svg
              xmlns="http://www.w3.org/2000/svg"
              fill="none"
              viewBox="0 0 24 24"
              stroke-width="1.5"
              stroke="currentColor"
              class="size-6"
            >
              <path
                stroke-linecap="round"
                stroke-linejoin="round"
                d="m12.75 15 3-3m0 0-3-3m3 3h-7.5M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
              />
            </svg>
          </a>
        </div>
      </div>
    </div>
    """
  end

  # Classes don't like string interpolation
  defp indicator_color(true), do: "bg-green-400"
  defp indicator_color(false), do: "bg-gray-400"

  @impl true
  def handle_async(:next_slide, {:ok, :ok}, socket) do
    if socket.assigns.auto_slide do
      socket = start_async(socket, :next_slide, fn -> :timer.sleep(@slide_duration) end)
      handle_event("next", nil, socket)
    else
      {:noreply, socket}
    end
  end

  @impl true
  def handle_event("previous", _, socket) do
    socket.assigns.active_card
    |> case do
      0 -> socket.assigns.total_cards - 1
      card -> card - 1
    end
    |> update_active_card(socket)
  end

  @impl true
  def handle_event("next", _, socket) do
    (socket.assigns.active_card + 1)
    |> rem(socket.assigns.total_cards)
    |> update_active_card(socket)
  end

  @impl true
  def handle_event("set-card", %{"card" => card}, socket) do
    {card, _} = Integer.parse(card)
    update_active_card(card, socket)
  end

  @impl true
  def handle_event("toggle-auto-slide", _, socket) do
    socket = assign(socket, :auto_slide, !socket.assigns.auto_slide)

    if socket.assigns.auto_slide do
      handle_async(:next_slide, {:ok, :ok}, socket)
    else
      {:noreply, socket}
    end
  end

  defp update_active_card(active_card, socket) do
    send(self(), {:active_card, active_card})
    {:noreply, assign(socket, :active_card, active_card)}
  end
end
