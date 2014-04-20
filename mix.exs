defmodule CyclomaticComplector.Mixfile do
  use Mix.Project

  def project do
    [app: :cyclomatic_complector,
     version: "0.0.1",
     elixir: "~> 0.13.0",
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [ applications: [:inets],
      mod: { CyclomaticComplector, [] },
      env: [
        couchdb_host: "localhost",
        couchdb_port: 5984,
        couchdb_credentials: {"admin", "secret"}
      ]
    ]
  end

  # List all dependencies in the format:
  #
  # { :foobar, git: "https://github.com/elixir-lang/foobar.git", tag: "0.1" }
  #
  # Type `mix help deps` for more examples and options
  defp deps do
    []
  end
end
