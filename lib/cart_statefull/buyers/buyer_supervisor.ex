defmodule CartStatefull.Buyers.BuyerSupervisor do
  @moduledoc """
  supervisor for buyer processes
  """

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, :ok, name: __MODULE__)
  end

  def init(:ok) do
    children = [
      worker(CartStatefull.Buyers.Buyer, [], restart: :temporary)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  def new_buyer do
    Supervisor.start_child(CartStatefull.Buyers.BuyerSupervisor, [])
  end
end
