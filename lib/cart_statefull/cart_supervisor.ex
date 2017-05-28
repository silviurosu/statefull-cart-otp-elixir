defmodule CartStatefull.CartSupervisor do
  @moduledoc """
  Supervisor for Carts processes
  Supervising is done using simple_one_for_one strategy a simplified version of
  one_for_one better suited to many dynamically started childrens

  Cart workers are temporary (when they complete they are not restarted)
  because carts are created and completed
  """

  use Supervisor

  def start_link do
    Supervisor.start_link(__MODULE__, [], name: __MODULE__)
  end

  def init([]) do
    children = [
      worker(CartStatefull.Cart, [], restart: :temporary)
    ]
    supervise(children, strategy: :simple_one_for_one)
  end

  def new_cart do
    Supervisor.start_child(__MODULE__, [])
  end
end
