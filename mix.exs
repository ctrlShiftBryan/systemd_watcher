defmodule SystemdWatcher.Mixfile do
  use Mix.Project

  def project do
    [app: :systemd_watcher,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [mod: {SystemdWatcher, []},
     applications: [:logger]]
  end

  defp aliases do
    ["test": ["test --no-start"]]
  end
  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:double, "~> 0.6.0", only: :test}]
  end
end
