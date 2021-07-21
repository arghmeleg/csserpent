defmodule CSSerpent.Rule do
  @moduledoc """
  A struct to represent a CSS rule.
  """

  defstruct [
    :props,
    :selector,
    :identifier,
    :raw,
    :rules,
    :value,
    :source
  ]

  @type t() :: %__MODULE__{
          selector: String.t(),
          props: list(),
          identifier: String.t(),
          raw: String.t(),
          rules: list(),
          value: String.t(),
          source: any()
        }
end
