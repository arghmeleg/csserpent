defmodule CSSerpent do
  @moduledoc """
  CSSerpent, the CSS parser.
  """

  @normal_rule_regex ~r/(?<selector>[^{@]+)\s*{\s*(?<props>[^{}]+)}/
  @regular_at_rule_regex ~r/(?<identifier>@(charset|import|namespace)+)\s+(?<value>[^\s]+);/
  @nested_at_rule_regex ~r/(?<nested_identifier>@\w+)\s+(?<nested_value>[^{]+)\s*{\s*(?<rules>.*)}/
  @comment_regex ~r/\/\*.*\*\//

  @rule_regex ~r/#{Regex.source(@regular_at_rule_regex)}|#{Regex.source(@nested_at_rule_regex)}|#{
                Regex.source(@normal_rule_regex)
              }/s

  defmodule Rule do
    defstruct [
      :props,
      :selector,
      :identifier,
      :raw,
      :rules,
      :value
    ]

    @type t() :: %__MODULE__{
            selector: String.t(),
            props: list(),
            identifier: String.t(),
            raw: String.t(),
            rules: list(),
            value: String.t()
          }
  end

  @spec parse(String.t()) :: list(Rule.t())
  def parse(body) when is_binary(body) do
    commentless_body = Regex.replace(@comment_regex, body, "")

    @rule_regex
    |> Regex.scan(commentless_body, capture: :first)
    |> List.flatten()
    |> Enum.map(fn css ->
      case Regex.named_captures(@rule_regex, css) do
        %{"nested_identifier" => nid} = capts when byte_size(nid) > 0 ->
          %Rule{
            props: [],
            selector: nil,
            raw: css,
            identifier: trim_or_nil(capts["nested_identifier"]),
            value: trim_or_nil(capts["nested_value"]),
            rules: parse(capts["rules"])
          }

        %{} = capts ->
          %Rule{
            props: parse_props(capts["props"]),
            selector: trim_or_nil(capts["selector"]),
            raw: css,
            identifier: trim_or_nil(capts["identifier"]),
            value: trim_or_nil(capts["value"])
          }

        _ ->
          nil
      end
    end)
    |> Enum.filter(& &1)
  end

  def parse(_body, _source), do: []

  defp parse_props(props) when is_binary(props) do
    props
    |> String.split(";")
    |> Enum.map(fn prop ->
      case String.split(prop, ":", parts: 2) do
        [prop, val] -> %{property: String.trim(prop), value: String.trim(val)}
        _ -> nil
      end
    end)
    |> Enum.filter(& &1)
  end

  defp parse_props(_), do: []

  defp trim_or_nil(string) when is_binary(string) do
    case String.trim(string) do
      "" -> nil
      val -> val
    end
  end

  defp trim_or_nil(_), do: nil
end
