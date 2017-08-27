defmodule CartTest do
  use ExUnit.Case, async: true

  alias CartStatefull.Cart
  alias CartStatefull.Cart.State
  alias CartStatefull.Buyer

  test "list all the items in the cart" do
    items = [{1, "Mere"}, {2, "Pere"}]
    {:reply, %{buyer: nil, items: result_items}, _, _} = Cart.handle_call({:list}, nil, %State{items: items})
    assert result_items == items |> Enum.map(fn({_, name})-> name end)
  end

  test "add item in the cart" do
    items = [{1, "Mere"}, {2, "Pere"}]
    new_item = {3, "Apples"}
    {:noreply, %{buyer: nil, items: result_items}, _} = Cart.handle_cast({:add_item, new_item}, %State{items: items})

    input_items = [new_item | items]

    assert result_items == input_items
  end

  test "add buyer in the cart" do
    buyer = %Buyer{name: "Silviu Rosu", email: "demo@example.com"}

    {:noreply, %{buyer: result_buyer}, _} = Cart.handle_cast({:add_buyer, buyer}, %State{items: []})

    assert result_buyer == buyer
  end

  test "remove item from the cart" do
    items = [{1, "Mere"}, {2, "Pere"}]
    {:noreply, %{buyer: nil, items: result_items}, _} = Cart.handle_cast({:remove_item, 1}, %State{items: items})

    [_ | expected_list] = items

    assert expected_list == result_items
  end

  test "handle timeout event" do
    {:stop, :timeout, state} = Cart.handle_info(:timeout, %State{})
    assert state
  end

  test "handle end process event" do
    {:stop, :normal, state} = Cart.handle_info(:end_process, %State{})
    assert state
  end
end
