defmodule CSSerpent.MixProject do
  use Mix.Project

  @description "CSSerpent is a CSS parsing library."
  @version "0.3.0"

  def project do
    [
      app: :csserpent,
      version: @version,
      description: @description,
      elixir: "~> 1.8",
      package: package(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      source_url: "https://github.com/arghmeleg/csserpent"
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp package do
    %{
      maintainers: ["Steve DeGele"],
      licenses: ["MIT"],
      files: [
        "lib",
        "test",
        "mix.exs",
        "README.md",
        "LICENSE"
      ],
      links: %{
        "GitHub" => "https://github.com/arghmeleg/csserpent"
      }
    }
  end
end
