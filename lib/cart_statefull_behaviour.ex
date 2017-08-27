defmodule CartStatefullBehaviour do
  @moduledoc """
  Specification for public methods
  """

  alias CartStatefull.Buyer

  @callback new_cart() :: {:ok, String.t} | {:error, atom}
  @callback terminate(String.t) :: :ok | {:error, String.t}
  @callback get_active_carts_uuids() :: {:ok, list(String.t)} | {:error, String.t}

  @callback get_cart_content(String.t) :: {:ok, list} | {:error, String.t}
  @callback add_item_to_cart(String.t, {integer, String.t}) :: :ok | {:error, String.t}
  @callback remove_item_from_cart(String.t, integer) :: :ok | {:error, String.t}

  @callback add_buyer_to_cart(String.t, Buyer.t) :: :ok | {:error, String.t}
end
