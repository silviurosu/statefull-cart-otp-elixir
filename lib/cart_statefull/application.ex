defmodule CartStatefull.Application do
  @moduledoc """
  Supervisor for the whole app
  It supervises: CartSupervisor, and Registry
  Supervising is done using one_for_one strategy (if a process terminates only that process is restarted)
  Childrens are always restarted in case they fail and terminate
  """

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      supervisor(CartStatefull.CartSupervisor, []),
      supervisor(Registry, [:unique, :cart_process_registry])
    ]
    opts = [strategy: :one_for_one, name: CartStatefull.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
