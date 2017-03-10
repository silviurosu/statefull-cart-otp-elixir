defmodule CartStatefull.Buyers.Buyer do
  @moduledoc """
  Buyer state in a specialized Agent
  """

  def start_link() do
    Agent.start_link(fn-> %{items: []} end, [])
  end

  def cart_content(pid) do
    Agent.get(pid, &(&1))
  end

  def add_item(pid, {id, name} ) do
    Agent.update(pid, fn(cart)->
      items = Map.get(cart, :items)
      %{cart | items: [{id, name} | items]}
    end)
  end

  def remove_item(pid, id ) do
    Agent.update(pid, fn(cart)->
      items = Map.get(cart, :items)
      %{cart | items: Enum.reject(items, fn({item_id, _name})-> item_id == id end)}
    end)
  end
end
