# SystemdWatcher

**TODO: Add description**

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed as:

  1. Add `systemd_watcher` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:systemd_watcher, "~> 0.1.0"}]
    end
    ```

  2. Ensure `systemd_watcher` is started before your application:

    ```elixir
    def application do
      [applications: [:systemd_watcher]]
    end
    ```

