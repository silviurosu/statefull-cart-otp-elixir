defmodule CartStatefull.CartSupervisor do
  @moduledoc """
  Supervisor for Carts processes
  Supervising is done using simple_one_for_one strategy, a simplified version of
  one_for_one better suited to many dynamically started childrens

  Cart workers are temporary (when they complete they are not restarted)
  because carts are created and completed
  """

  use Supervisor

  @cart_registry_name :cart_process_registry

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [
      worker(CartStatefull.Cart, [], restart: :temporary)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  @doc """
  Start a new cart process.
  Generates a uuid and sends this uuid to Cart process
  """
  @spec new_cart :: {:ok, String.t} | {:error, :process_already_exists}
  def new_cart do
    uuid = UUID.uuid1()
    case Supervisor.start_child(__MODULE__, [uuid]) do
      {:ok, _pid} -> {:ok, uuid}
      {:error, {:already_started, _pid}} -> {:error, :process_already_exists}
      other -> {:error, other}
    end
  end

  @doc """
    Terminates a cart process.
  """
  @spec terminate(String.t) :: :ok | {:error, String.t}
  def terminate(uuid) when is_binary(uuid) do
    case find_cart_process(uuid) do
      nil -> {:error, "Cart already stopped"}
      pid ->
        Process.send(pid, :end_process, [])
        :ok
    end
  end

  @doc """
  Get all uuids for active carts
  """
  @spec get_active_carts_uuids :: {:ok, list(String.t)} | {:error, String.t}
  def get_active_carts_uuids do
    uuids = __MODULE__
            |> Supervisor.which_children()
            |> Enum.map(&cart_process_uuid/1)
    {:ok, uuids}
  end

  defp cart_process_uuid({_, cart_proc_pid, _, _}) do
    @cart_registry_name
      |> Registry.keys(cart_proc_pid)
      |> List.first
  end

  # Returns the pid for the `uuid` stored in the registry
  defp find_cart_process(uuid) do
    case Registry.lookup(@cart_registry_name, uuid) do
      [{pid, _}] -> pid
      [] -> nil
    end
  end
end
