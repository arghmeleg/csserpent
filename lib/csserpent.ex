defmodule CSSerpent do
  @moduledoc """
  CSSerpent, the CSS parser.
  """
  alias CSSerpent.Rule

  @normal_rule_regex ~r/(?<selector>[^{@]+)\s*{\s*(?<props>[^{}]+)}/
  @regular_at_rule_regex ~r/(?<identifier>@(charset|import|namespace)+)\s+(?<value>[^\s]+);/
  @nested_at_rule_value_regex ~r/(?<nested_identifier_value>@[\w\-]+)\s+(?<nested_value>[^{}]+)\s*{\s*(?<nested_rules>([^{}]+{([^{}]+{[^{}]*}|[^{}]*)*}\s*)*)\s*}/
  @nested_at_rule_regex ~r/(?<nested_identifier>@[\w\-]+)\s*{\s*(?<nested_props>.*?)}/
  @comment_regex ~r/\/\*.*\*\//

  @rule_regex ~r/#{Regex.source(@regular_at_rule_regex)}|#{
                Regex.source(@nested_at_rule_value_regex)
              }|#{Regex.source(@nested_at_rule_regex)}|#{Regex.source(@normal_rule_regex)}/s

  @doc """
  Parses CSS text from a string.
  ## Example
      iex> CSSerpent.parse("p { color: green }")
      [
        %CSSerpent.Rule{
          identifier: nil,
          props: [%{property: "color", value: "green"}],
          raw: "p { color: green }",
          rules: nil,
          selector: "p",
          source: nil,
          value: nil
        }
      ]
  """
  @spec parse(String.t(), any()) :: list(Rule.t())
  def parse(body, source \\ nil)

  def parse(body, source) when is_binary(body) do
    commentless_body = Regex.replace(@comment_regex, body, "")

    @rule_regex
    |> Regex.scan(commentless_body, capture: :first)
    |> List.flatten()
    |> Enum.map(fn css ->
      case Regex.named_captures(@rule_regex, css) do
        %{"nested_identifier_value" => nid} = capts when byte_size(nid) > 0 ->
          %Rule{
            props: [],
            selector: nil,
            raw: css,
            identifier: trim_or_nil(capts["nested_identifier_value"]),
            value: trim_or_nil(capts["nested_value"]),
            rules: parse(capts["nested_rules"], source),
            source: source
          }

        %{"nested_identifier" => nid} = capts when byte_size(nid) > 0 ->
          %Rule{
            props: parse_props(capts["nested_props"]),
            selector: nil,
            raw: css,
            identifier: trim_or_nil(capts["nested_identifier"])
          }

        %{} = capts ->
          %Rule{
            props: parse_props(capts["props"]),
            selector: trim_or_nil(capts["selector"]),
            raw: css,
            identifier: trim_or_nil(capts["identifier"]),
            value: trim_or_nil(capts["value"]),
            source: source
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

  @doc """
  Converts parsed CSS to raw CSS.
  ## Example
      iex> CSSerpent.raw_css(%CSSerpent.Rule{props: [%{property: "color", value: "green"}], selector: "p"})
      "p{color:green}"

      iex> CSSerpent.raw_css([%CSSerpent.Rule{props: [%{property: "color", value: "blue"}], selector: "p"}])
      "p{color:blue}"
  """
  @spec raw_css(list(Rule.t()) | Rule.t()) :: String.t()
  def raw_css(rules) when is_list(rules) do
    Enum.map_join(rules, &raw_css/1)
  end

  def raw_css(%{identifier: id, value: v, rules: r})
      when is_binary(id) and is_binary(v) and is_list(r) do
    "#{id} #{v}{#{raw_css(r)}}"
  end

  def raw_css(%{identifier: id, value: v}) when is_binary(id) and is_binary(v) do
    "#{id} #{v};"
  end

  def raw_css(%{selector: s, props: props}) do
    "#{s}{#{raw_props(props)}}"
  end

  defp raw_props(props) when is_list(props) do
    Enum.map_join(props, ";", &raw_props/1)
  end

  defp raw_props(prop) do
    "#{prop.property}:#{prop.value}"
  end

  defp trim_or_nil(string) when is_binary(string) do
    case String.trim(string) do
      "" -> nil
      val -> val
    end
  end

  defp trim_or_nil(_), do: nil
end
