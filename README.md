[![CSSerpent version](https://img.shields.io/hexpm/v/csserpent.svg)](https://hex.pm/packages/csserpent)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/csserpent/)

# CSSerpent

[Documentation](https://hexdocs.pm/csserpent).

CSSerpent parses css strings and returns structured css data.

```elixir
iex(1)> CSSerpent.parse(".main { max-width: 1000px; }")
[
  %CSSerpent.Rule{
    identifier: nil,
    props: [%{property: "max-width", value: "1000px"}],
    raw: ".main { max-width: 1000px; }",
    rules: nil,
    selector: ".main",
    value: nil,
    source: nil
  }
]
```

## Installation

The package can be installed by adding `csserpent` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:csserpent, "~> 0.3.0"}
  ]
end
```
