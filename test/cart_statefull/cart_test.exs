defmodule CartTest do
  use ExUnit.Case, async: true

  alias CartStatefull.Cart
  alias CartStatefull.Cart.State

  test "list all the items in the cart" do
    items = [{1, "Mere"}, {2, "Pere"}]
    {:reply, %{buyer: nil, items: result_items}, _, _} = Cart.handle_call({:list}, nil, %State{items: items})
    assert result_items == items |> Enum.map(fn({_, name})-> name end)
  end
end
