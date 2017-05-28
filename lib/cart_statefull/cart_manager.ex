defmodule CartStatefull.CartManager do
  @moduledoc """
    It takes care of creating carts for buyers and keeping references to them.
    We use two maps for storing buyer carts:
     - carts - we keep pairs of id => {name, pid, ref}
     - refs - we keep pairs of ref => id to be able to find the cart id when
              a cart process terminates
  """

  use GenServer

  alias CartStatefull.CartSupervisor
  alias CartStatefull.Cart

  def start_link do
    GenServer.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    carts = %{}
    refs = %{}
    {:ok, {carts, refs}}
  end

  @doc """
   Create a new cart. We execute 'cast' on GenServer (asynchronous operation)
  """
  def create(name) when is_binary(name) do
    GenServer.cast(__MODULE__, {:create, name})
  end

  @doc """
  Terminates a cart. We execute 'cast' on GenServer (asynchronous operation)
  """
  def remove(uuid) do
    GenServer.cast(__MODULE__, {:remove, uuid})
  end

  @doc """
  List all carts. We use 'call' on GenServer (synchronous operation)
  """
  def list do
    GenServer.call(__MODULE__, {:list})
  end

  @doc """
   Add item to buyer cart. We use 'cast' on GenServer (asynchronous operation)
  """
  def add_to_cart(uuid, item) do
    GenServer.cast(__MODULE__, {:add_to_cart, uuid, item})
  end

  @doc """
   Removes item from buyer cart. We use 'cast' on GenServer (asynchronous operation)
  """
  def remove_from_cart(uuid, item_id) do
    GenServer.cast(__MODULE__, {:remove_from_cart, uuid, item_id})
  end

  @doc """
  Handles create cart action.
  Using CartSupervisor we create a new cart process.
  We take the ref for this process with Process.monitor.
  We generate an unique id for the cart using a whatever strategy.
  We store the **ref => id** in map of references
  We store **id => {name, pid, ref}** in the map of carts
  """
  def handle_cast({:create, name}, {carts, refs}) do
    {:ok, pid} = CartSupervisor.new_cart()
    ref = Process.monitor(pid)
    uuid = UUID.uuid1()
    refs = Map.put(refs, ref, uuid)
    carts = Map.put(carts, uuid, {name, pid, ref})
    {:noreply, {carts, refs}}
  end

  @doc """
    Removes a cart from memory terminating the process
  """
  def handle_cast({:remove, uuid}, {carts, refs}) do
    {{_name, pid, _ref}, carts} = Map.pop(carts, uuid)
    Process.exit(pid, :kill)
    {:noreply, {carts, refs}}
  end


  def handle_cast({:add_to_cart, uuid, item}, {carts, refs}) do
    {_name, pid, _ref} = Map.get(carts, uuid)
    Cart.add_item(pid, item)
    {:noreply, {carts, refs}}
  end

  def handle_cast({:remove_from_cart, uuid, item_id}, {carts, refs}) do
    {_name, pid, _ref} = Map.get(carts, uuid)
    Cart.remove_item(pid, item_id)
    {:noreply, {carts, refs}}
  end

  def handle_call({:list}, _from, {carts, _refs} = state) do
    list = Enum.map(carts, fn {uuid, {name, pid, _ref}} ->
      %{uuid: uuid, name: name, cart_content: Cart.cart_content(pid)}
    end)
    {:reply, list, state}
  end

  def handle_info({:DOWN, ref, :process, _pid, _reason}, {carts, refs}) do
    {uuid, refs} = Map.pop(refs, ref)
    carts = Map.delete(carts, uuid)
    {:noreply, {carts, refs}}
  end

  def handle_info(_msg, state) do
    {:noreply, state}
  end
end

