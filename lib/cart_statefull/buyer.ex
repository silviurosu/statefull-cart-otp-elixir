defmodule CartStatefull.Buyer do
  @moduledoc """
  Buyer struct
  """
  @enforce_keys [:name, :email]

  defstruct [:name, :email]

  @type t :: %__MODULE__{
    name: String.t,
    email: String.t
  }
end
