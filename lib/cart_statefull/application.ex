defmodule CartStatefull.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    children = [
      worker(CartStatefull.Buyers.Manager, []),
      supervisor(CartStatefull.Buyers.BuyerSupervisor, []),
      supervisor(Registry, [:unique, :buyers_registry])
    ]
    opts = [strategy: :one_for_one, name: CartStatefull.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
