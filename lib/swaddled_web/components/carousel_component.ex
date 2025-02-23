defmodule SwaddledWeb.CarouselComponent do
  @moduledoc """
  A pure Liveview/Tailwind solution for a carousel.

  This details of this carousel are specfically geared towards showing the
  Swaddled. To make this more generic, can make the `.carousel` component
  accept more options, such as setting the `slide_duration`, hide/show the
  indicators or controls, etc. Should also allow each card to have it's own
  look, too.

  ## Configuration

  - Add as many `:cards` elements as you'd like, but only tested with up to 6.
  - Change how long a slide is shown by updating `@default_slide_duration`.

  ## Usage

  <.carousel id="my-carousel">
    <:cards title="Card Title" image_src={~p"/images/path_to_image.jpg"}>
      Content of card goes here!
    </:cards>
  </.carousel>
  """

  use SwaddledWeb, :live_component

  @default_slide_duration 10_000

  @impl true
  @spec mount(map()) :: {:ok, map()}
  def mount(socket) do
    {:ok,
     socket
     |> assign(:active_card, 0)
     |> assign(:auto_slide, true)
     |> start_async(:next_slide, fn -> :timer.sleep(slide_duration()) end)}
  end

  @impl true
  def render(assigns) do
    ~H"""
    <div id={@id} class="grid grid-cols-1 justify-items-center">
      <%= for {card, i} <- Enum.with_index(@cards) do %>
        <.card
          active_card={@active_card}
          current_card={i}
          image_src={card.image_src}
          title={card.title}
        >
          {render_slot(card)}
        </.card>
      <% end %>

      <.indicators
        active_card={@active_card}
        card_values={@total_cards - 1}
        id={@id}
        myself={@myself}
      />
      <.controls auto_slide={@auto_slide} id={@id} myself={@myself} />
    </div>
    """
  end

  @impl true
  def handle_async(:next_slide, {:ok, :ok}, socket) do
    if socket.assigns.auto_slide do
      socket = start_async(socket, :next_slide, fn -> :timer.sleep(slide_duration()) end)
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
    {:noreply, assign(socket, :active_card, active_card)}
  end

  slot :cards do
    attr :image_src, :string, required: true
    attr :title, :string, required: true
  end

  attr :id, :string, required: true

  def carousel(assigns) do
    ~H"""
    <.live_component module={__MODULE__} id={@id} cards={@cards} total_cards={Enum.count(@cards)} />
    """
  end

  slot :inner_block, required: true
  attr :active_card, :integer, required: true
  attr :current_card, :integer, required: true
  attr :image_src, :string, required: true
  attr :title, :string, required: true

  defp card(assigns) do
    ~H"""
    <div :if={@active_card == @current_card} class="w-4/5 aspect-[16/7] min-w-[512px] min-h-56 flex">
      <div
        class="w-1/2 h-full flex-none bg-cover rounded-l lg:rounded-l-[20px] text-center overflow-hidden bg-center"
        style={"background-image: url('#{@image_src}')"}
        title={@title}
      >
      </div>
      <div class="p-2 w-1/2 items-center xs:text-xs sm:text-sm lg:text-md xl:text-2xl font-sans h-full border-r border-b border-l border-t border-gray-400 bg-white rounded-r lg:rounded-r-[20px] flex flex-col overflow-scroll">
        <h1 class="mb-4 font-bold">{@title}</h1>
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end

  defp controls(assigns) do
    ~H"""
    <div class="flex justify-center">
      <div id={"#{@id}-previous"} phx-click="previous" phx-target={@myself} class="cursor-pointer">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="size-8"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="m11.25 9-3 3m0 0 3 3m-3-3h7.5M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
          />
        </svg>
      </div>
      <div
        id={"#{@id}-pause"}
        class="mx-4 cursor-pointer"
        phx-click="toggle-auto-slide"
        phx-target={@myself}
      >
        <svg
          :if={@auto_slide}
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="size-8"
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
          class="size-8"
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
      <div id={"#{@id}-next"} phx-click="next" phx-target={@myself} class="cursor-pointer">
        <svg
          xmlns="http://www.w3.org/2000/svg"
          fill="none"
          viewBox="0 0 24 24"
          stroke-width="1.5"
          stroke="currentColor"
          class="size-8"
        >
          <path
            stroke-linecap="round"
            stroke-linejoin="round"
            d="m12.75 15 3-3m0 0-3-3m3 3h-7.5M21 12a9 9 0 1 1-18 0 9 9 0 0 1 18 0Z"
          />
        </svg>
      </div>
    </div>
    """
  end

  defp indicators(assigns) do
    ~H"""
    <div class="flex justify-center h-8">
      <div class="flex items-center justify-center gap-3">
        <%= for i <- 0..@card_values do %>
          <div
            id={"#{@id}-indicator-#{i}"}
            class={"w-[30px] h-[3px] cursor-pointer #{indicator_color(@active_card == i)}"}
            phx-click="set-card"
            phx-target={@myself}
            phx-value-card={i}
          />
        <% end %>
      </div>
    </div>
    """
  end

  # Classes don't like string interpolation
  defp indicator_color(true), do: "bg-green-400"
  defp indicator_color(false), do: "bg-gray-400"

  # Want a much lower time in tests so tests don't run that long
  defp slide_duration do
    case Application.get_env(:swaddled, :env) do
      :test -> 10
      _ -> @default_slide_duration
    end
  end
end
