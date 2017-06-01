defmodule CartStatefull.Buyer do
  @moduledoc """
  Buyer struct
  """

  defstruct [:name, :email]

  @type t :: %__MODULE__{
    name: String.t,
    email: String.t
  }
end
