defmodule CSSerpentTest do
  use ExUnit.Case
  doctest CSSerpent

  alias CSSerpent.Rule

  describe "raw css" do
    test "normal rule" do
      raw_css =
        CSSerpent.raw_css(%Rule{selector: "body", props: [%{property: "color", value: "green"}]})

      assert raw_css == "body{color:green}"
    end

    test "@charset" do
      raw_css = CSSerpent.raw_css(%Rule{identifier: "@charset", value: "\"utf-8\""})

      assert raw_css == "@charset \"utf-8\";"
    end

    test "nested at rule" do
      rule = %Rule{
        identifier: "@media",
        value: "only screen and (max-width: 600px)",
        rules: [
          %Rule{selector: "body", props: [%{property: "color", value: "blue"}]}
        ]
      }

      raw_css = CSSerpent.raw_css(rule)

      assert raw_css == "@media only screen and (max-width: 600px){body{color:blue}}"
    end

    test "conditional at rules" do
      css = ~s|
        @supports (display: flex) {
          @media screen and (min-width: 900px) {
            article {
              display: flex;
            }
          }
        }
      |

      raw_css =
        css
        |> CSSerpent.parse()
        |> CSSerpent.raw_css()

      assert raw_css ==
               "@supports (display: flex){@media screen and (min-width: 900px){article{display:flex}}}"
    end
  end

  test "normal selector" do
    assert_rule(
      ~s(body { color: green }),
      %{selector: "body", props: [%{property: "color", value: "green"}]}
    )
  end

  describe "regular @ rules" do
    test "@charset" do
      assert_rule(~s(@charset "utf-8";), %{identifier: "@charset", value: ~s("utf-8")})
    end

    test "@import" do
      assert_rule(~s(@import 'custom.css';), %{identifier: "@import", value: ~s('custom.css')})
    end

    test "@import url" do
      assert_rule(
        ~s|@import url("domain.com/style.css");|,
        %{identifier: "@import", value: ~s|url("domain.com/style.css")|}
      )
    end
  end

  describe "nested @ rules" do
    test "@keyframes" do
      css = ~s|
        @keyframes spinAround {
          from {
            transform: rotate(0deg);
          }

          to {
            transform: rotate(359deg);
          }
        }
      |

      [rule] = CSSerpent.parse(css)

      assert rule.identifier == "@keyframes"
      assert rule.value == "spinAround"
      assert Enum.count(rule.rules) == 2
      assert Enum.any?(rule.rules, &(&1.selector == "to"))
      assert Enum.any?(rule.rules, &(&1.selector == "from"))
    end

    test "@font-face" do
      css =
        ~s|@font-face{font-style:normal;font-family:biosans;font-weight:400;font-display:swap;src:url(../fonts/biosans-regular-webfont.acf44e8d.woff2) format("woff2"),url(../fonts/biosans-regular-webfont.ef972623.woff) format("woff")}|

      [rule] = CSSerpent.parse(css)
      assert rule.identifier == "@font-face"
      assert Enum.count(rule.props) == 5
    end

    test "non-greedy font faces" do
      css =
        ~s|@font-face{font-family:bio;src:url(bio.woff2)}@font-face{font-family:biosans;src:url(biosans.woff2)}|

      rules = CSSerpent.parse(css)
      assert Enum.count(rules) == 2
    end

    test "multiple comma seperated @media's" do
      css =
        ~s|@media print,screen and (min-width:900px){.columns{margin:0 auto;width:100%;max-width:1000px}}.layout--cas .columns{padding:8px 32px 24px}|

      rules = CSSerpent.parse(css)
      assert Enum.count(rules) == 2
    end
  end

  describe "conditional @ rules" do
    test "@supports" do
      css = ~s|
        @supports (display: flex) {
          @media screen and (min-width: 900px) {
            article {
              display: flex;
            }
          }
        }
      |

      [rule] = CSSerpent.parse(css)

      assert rule.identifier == "@supports"
      assert rule.value == "(display: flex)"
    end
  end

  defp assert_rule(string, map) do
    [rule] = CSSerpent.parse(string)

    Enum.each(map, fn {k, v} ->
      assert Map.get(rule, k) == v
    end)
  end

  # TODO test / fix content
end
