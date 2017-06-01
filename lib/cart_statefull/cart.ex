defmodule CartStatefull.Cart do
  @moduledoc """
  Cart instance
  """

  use GenServer
  require Logger

  alias CartStatefull.Buyer

  @cart_registry_name :cart_process_registry
  @cart_not_found_message "Cart not found"
  @default_timeout 24 * 60 * 60 * 1000 # 24 hours. The process will terminate after
                                       # this timeout of inactivity

  defstruct [:items, :uuid, :buyer]

  def start_link(uuid) when is_binary(uuid) do
    GenServer.start_link(__MODULE__, [uuid], name: name_from_registry(uuid))
  end

  def init([uuid]) do
    # Add a msg to the process mailbox to
    # tell this process to run initialisation actions`

    # send(self(), :init_cart_data)

    Logger.info("Process created... Cart UUID: #{uuid}")

    # Set initial state and return from `init`
    {:ok, %__MODULE__{uuid: uuid, items: []}}
  end

  @doc """
    List cart content
  """
  @spec cart_content(String.t) :: {:ok, list} | {:error, String.t}
  def cart_content(uuid) do
    if (cart_process_exist?(uuid)) do
      GenServer.call(name_from_registry(uuid), {:list})
    else
      {:error, @cart_not_found_message}
    end
  end

  @doc """
    Add item to cart. Item format: {id, name}
  """
  @spec add_item(String.t, {integer, String.t}) :: :ok | {:error, String.t}
  def add_item(uuid, item) do
    if (cart_process_exist?(uuid)) do
      GenServer.cast(name_from_registry(uuid), {:add_item, item})
      :ok
    else
      {:error, @cart_not_found_message}
    end
  end

  @doc """
    Add buyer to cart.
  """
  @spec add_buyer(String.t, Buyer.t) :: :ok | {:error, String.t}
  def add_buyer(uuid, %Buyer{} = buyer) do
    if (cart_process_exist?(uuid)) do
      GenServer.cast(name_from_registry(uuid), {:add_buyer, buyer})
      :ok
    else
      {:error, @cart_not_found_message}
    end
  end

  @doc """
    Remove item from cart by id
  """
  @spec remove_item(String.t, integer) :: :ok | {:error, String.t}
  def remove_item(uuid, item_id) do
    if (cart_process_exist?(uuid)) do
      GenServer.cast(name_from_registry(uuid), {:remove_item, item_id})
      :ok
    else
      {:error, @cart_not_found_message}
    end
  end

  # HANDLERS for GenServer actions
  def handle_call({:list}, _from, %__MODULE__{items: items} = state) do
    item_names = Enum.map(items, fn({_id, name}) -> name end)
    {:reply, %{buyer: state.buyer, items: item_names}, state, @default_timeout}
  end

  def handle_cast({:add_item, item}, %__MODULE__{items: items} = state) do
    {:noreply, %__MODULE__{state | items: [item | items]}, @default_timeout}
  end

  def handle_cast({:add_buyer, buyer}, state) do
    {:noreply, %__MODULE__{state | buyer: buyer}, @default_timeout}
  end

  def handle_cast({:remove_item, item_id}, %__MODULE__{items: items} = state) do
    new_items = Enum.reject(items, fn({id, _name}) -> item_id == id end)
    {:noreply, %__MODULE__{state | items: new_items}, @default_timeout}
  end

  def handle_info(:timeout, state) do
    #TODO - persist current cart before shutting down
    Logger.info("Stopping Cart Process by timeout. UUID: #{state.uuid}")
    {:stop, :timeout, state}
  end

  @doc """
    Gracefully end this process
  """
  def handle_info(:end_process, state) do
    #TODO - persist current cart before shutting down
    Logger.info("Cart Process manualy stopped. uuid: #{state.uuid}")
    {:stop, :normal, state}
  end

  defp cart_process_exist?(uuid) do
    case Registry.lookup(@cart_registry_name, uuid) do
      [{_pid, _}] -> true
      [] -> false
    end
  end

  @doc """
  Registry lookup handler
  """
  defp name_from_registry(uuid) do
    {:via, Registry, {@cart_registry_name, uuid}}
  end
end
