defmodule CartStatefull.Buyers.Manager do
  @moduledoc """
  Buyers carts manager
  """
  use GenServer

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    buyers = %{}
    refs = %{}
    {:ok, {buyers, refs}}
  end

  def add(name) when is_binary(name) do
    GenServer.cast(__MODULE__, {:add, name})
  end

  def remove(id) do
    GenServer.cast(__MODULE__, {:remove, id})
  end

  def list do
    GenServer.call(__MODULE__, {:list})
  end

  def add_to_cart(id, item) do
    GenServer.cast(__MODULE__, {:add_to_cart, id, item})
  end

  def remove_from_cart(id, item_id) do
    GenServer.cast(__MODULE__, {:remove_from_cart, id, item_id})
  end

  def handle_cast({:add, name}, {buyers, refs}) do
    {:ok, pid} = CartStatefull.Buyers.BuyerSupervisor.new_buyer()
    ref = Process.monitor(pid)
    id = auto_increment(buyers)
    refs = Map.put(refs, ref, id)
    buyers = Map.put(buyers, id, {name, pid, ref})
    {:noreply, {buyers, refs}}
  end

  def handle_cast({:remove, id}, {buyers, refs}) do
    {{_name, pid, _ref}, buyers} = Map.pop(buyers, id)
    Process.exit(pid, :kill)
    {:noreply, {buyers, refs}}
  end

  def handle_cast({:add_to_cart, id, item}, {buyers, refs}) do
    {_name, pid, _ref} = Map.get(buyers, id)
    CartStatefull.Buyers.Buyer.add_item(pid, item)
    {:noreply, {buyers, refs}}
  end

  def handle_cast({:remove_from_cart, id, item_id}, {buyers, refs}) do
    {_name, pid, _ref} = Map.get(buyers, id)
    CartStatefull.Buyers.Buyer.remove_item(pid, item_id)
    {:noreply, {buyers, refs}}
  end

  def handle_call({:list}, _from, {buyers, _refs} = state) do
    list = Enum.map(buyers, fn {id, {name, pid, _ref}} ->
      %{id: id, name: name, cart_content: CartStatefull.Buyers.Buyer.cart_content(pid)}
    end)
    {:reply, list, state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {buyers, refs}) do
    {id, refs} = Map.pop(refs, ref)
    buyers = Map.delete(buyers, id)
    {:noreply, {buyers, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end

  defp auto_increment(buyers) when buyers == %{}, do: 1
  defp auto_increment(buyers) do
    Map.keys(buyers)
    |> List.last
    |> Kernel.+(1)
  end

  defp via_tuple(buyer_id) do
    {:via, Registry, {:buyers_registry, buyer_id}}
  end
end
