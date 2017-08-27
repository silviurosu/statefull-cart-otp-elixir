defmodule CartStatefull.RegistryHelper do
  @moduledoc """
  Registry helper methods
  """

  @registry_name :cart_process_registry

  @doc """
  Check if process specified by uuid exist in registry
  """
  def process_exist?(uuid) do
    case Registry.lookup(@registry_name, uuid) do
      [{_pid, _}] -> true
      [] -> false
    end
  end

  @doc """
  Compose the tuple used by Registry
  """
  def via_tuple(uuid) do
    {:via, Registry, {@registry_name, uuid}}
  end
end
