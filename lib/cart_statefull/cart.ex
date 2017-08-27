defmodule CartStatefull.Cart do
  @moduledoc """
  Cart instance
  """

  use GenServer
  require Logger

  alias CartStatefull.RegistryHelper

  @default_timeout 24 * 60 * 60 * 1000 # 24 hours. The process will terminate after
                                       # this timeout of inactivity

  defstruct [:items, :uuid, :buyer]

  def start_link(uuid) when is_binary(uuid) do
    GenServer.start_link(__MODULE__, [uuid], name: RegistryHelper.via_tuple(uuid))
  end

  def init([uuid]) do
    # Add a msg to the process mailbox to
    # tell this process to run initialisation actions`

    # send(self(), :init_cart_data)

    Logger.info("Process created... Cart UUID: #{uuid}")

    # Set initial state and return from `init`
    {:ok, %__MODULE__{uuid: uuid, items: []}}
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
end
