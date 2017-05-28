defmodule CartStatefull.Cart do
  @moduledoc """
  Cart instance
  """

  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, %{items: []})
  end

  @doc """
    List cart content
  """
  def cart_content(pid) do
    GenServer.call(pid, {:list})
  end

  @doc """
    Add item to cart. Item format: {id, name}
  """
  def add_item(pid, item) do
    GenServer.cast(pid, {:add_item, item})
  end

  @doc """
    Remove item from cart by id
  """
  def remove_item(pid, item_id) do
    GenServer.cast(pid, {:remove_item, item_id})
  end

  # HANDLERS for GenServer actions
  def handle_call({:list}, _from, %{items: items} = cart) do
    list = Enum.map(items, fn({_id, name}) -> name end)
    {:reply, list, cart}
  end

  def handle_cast({:add_item, item}, %{items: items} = cart) do
    {:noreply, %{cart | items: [item | items]}}
  end

  def handle_cast({:remove_item, item_id}, %{items: items} = cart) do
    new_items = Enum.reject(items, fn({id, name}) -> item_id == id end)
    {:noreply, %{cart | items: new_items}}
  end
end
