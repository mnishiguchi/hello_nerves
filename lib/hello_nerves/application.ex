defmodule HelloNerves.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  # https://hexdocs.pm/nerves/advanced-configuration.html#partitions
  @nerves_data_dir "/data"

  def start(_type, _args) do
    # Form an Erlang cluster.
    KantanCluster.start(node: "nerves", cookie: :hello, connect_to: [])

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: HelloNerves.Supervisor]

    children =
      [
        # Children for all targets
      ] ++ children(target())

    Supervisor.start_link(children, opts)
  end

  # List all child processes to be supervised
  def children(:host) do
    [
      # Children that only run on the host
    ]
  end

  def children(_target) do
    [
      # Children for all targets except host
      {CubDB, [data_dir: @nerves_data_dir, name: CubDB]},
      {HelloNerves.SGP40States.Persister, nil},
      {HelloNerves.Worker, nil}
    ]
  end

  def target() do
    Application.get_env(:hello_nerves, :target)
  end
end
