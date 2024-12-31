defmodule SwaddledWeb.CarouselCardComponent do
  @moduledoc """
  These cards are used specifically for carousels and the attributes are geared
  for that, such as `hidden` by default.
  """
  use SwaddledWeb, :html

  slot :inner_block, required: true
  attr :image_src, :string, required: true
  attr :title, :string, required: true

  def card(assigns) do
    ~H"""
    <div class="max-w-sm w-full lg:max-w-full lg:flex h-56 lg:h-96">
      <div
        class="h-48 lg:h-auto w-1/2 flex-none bg-cover rounded-l-[20px] text-center overflow-hidden bg-center"
        style={"background-image: url('#{@image_src}')"}
        title={@title}
      >
      </div>
      <div class="p-8 w-1/2 text-lg font-serif h-full border-r border-b border-l border-gray-400 lg:border-l-0 lg:border-t lg:border-gray-400 bg-white rounded-b lg:rounded-b-none lg:rounded-r-[20px] p-4 flex flex-col justify-center leading-normal">
        {render_slot(@inner_block)}
      </div>
    </div>
    """
  end
end
