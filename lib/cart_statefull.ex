defmodule CartStatefull do
  @moduledoc """
  External Interface for the whole application
  """

  alias CartStatefull.RegistryHelper
  alias CartStatefull.Buyer

  @behaviour CartStatefullBehaviour

  @cart_not_found_message "Cart not found"

  @doc """
  Create new cart. Returns the uuid of the cart
  """
  @impl true
  defdelegate new_cart(), to: CartStatefull.CartSupervisor

  @doc """
  Termiate cart specified by uuid
  """
  @impl true
  defdelegate terminate(uuid), to: CartStatefull.CartSupervisor

  @doc """
  Get uuid list for all active carts
  """
  @impl true
  defdelegate get_active_carts_uuids(), to: CartStatefull.CartSupervisor

  @doc """
  Get content of the cart.
  Returns buyer info and the list of items
  """
  @impl true
  def get_cart_content(uuid) when is_binary(uuid) do
    if (RegistryHelper.process_exist?(uuid)) do
      GenServer.call(RegistryHelper.via_tuple(uuid), {:list})
    else
      {:error, @cart_not_found_message}
    end
  end

  @doc """
  Add item to cart. Item format: {id, name}
  """
  @impl true
  def add_item_to_cart(uuid, {id, name}=item) when is_binary(uuid) and is_integer(id)
                                      and is_binary(name) do
    if (RegistryHelper.process_exist?(uuid)) do
      GenServer.cast(RegistryHelper.via_tuple(uuid), {:add_item, item})
      :ok
    else
      {:error, @cart_not_found_message}
    end
  end

  @doc """
  Add buyer info to cart.
  """
  @impl true
  def add_buyer_to_cart(uuid, %Buyer{} = buyer) when is_binary(uuid) do
    if (RegistryHelper.process_exist?(uuid)) do
      GenServer.cast(RegistryHelper.via_tuple(uuid), {:add_buyer, buyer})
      :ok
    else
      {:error, @cart_not_found_message}
    end
  end

  @doc """
  Remove item from cart by item id
  """
  @impl true
  def remove_item_from_cart(uuid, item_id) when is_binary(uuid) and is_integer(item_id) do
    if (RegistryHelper.process_exist?(uuid)) do
      GenServer.cast(RegistryHelper.via_tuple(uuid), {:remove_item, item_id})
      :ok
    else
      {:error, @cart_not_found_message}
    end
  end
end
