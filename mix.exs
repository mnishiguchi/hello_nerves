defmodule HelloNerves.MixProject do
  use Mix.Project

  @app :hello_nerves
  @version "0.1.0"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      archives: [nerves_bootstrap: "~> 1.10"],
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      build_embedded: true,
      deps: deps(),
      releases: [{@app, release()}],
      preferred_cli_target: [run: :host, test: :host]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      mod: {HelloNerves.Application, []},
      extra_applications: [:logger, :runtime_tools, :inets]
    ]
  end

  # Ensure test/support is compiled
  defp elixirc_paths(:dev), do: ["lib", "test/support"]
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      # Dependencies for all targets
      {:nerves, "~> 1.7.4", runtime: false},
      {:shoehorn, "~> 0.7.0"},
      {:ring_logger, "~> 0.8.1"},
      {:toolshed, "~> 0.2.13"},
      {:nerves_runtime, "~> 0.11.3"},
      {:nerves_pack, "~> 0.6.0"},
      {:aht20, "~> 0.4"},
      {:bmp280, "~> 0.2"},
      {:elixir_bme680, "~> 0.2"},
      {:jason, "~> 1.2"},
      {:req, "~> 0.2.1"},
      {:plug, "~> 1.7"},
      {:cubdb, "~> 1.0"},
      {:phoenix_pubsub, "~> 2.0"},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.0.0", only: [:dev, :test]},

      # Dependencies for specific targets
      {:nerves_system_rpi, "~> 1.15", runtime: false, targets: :rpi},
      {:nerves_system_rpi0, "~> 1.15", runtime: false, targets: :rpi0},
      {:nerves_system_rpi2, "~> 1.15", runtime: false, targets: :rpi2},
      {:nerves_system_rpi3, "~> 1.15", runtime: false, targets: :rpi3},
      {:nerves_system_rpi3a, "~> 1.15", runtime: false, targets: :rpi3a},
      {:nerves_system_rpi4, "~> 1.15", runtime: false, targets: :rpi4},
      {:nerves_system_bbb, "~> 2.10", runtime: false, targets: :bbb},
      {:nerves_system_osd32mp1, "~> 0.6", runtime: false, targets: :osd32mp1},
      {:nerves_system_x86_64, "~> 1.15", runtime: false, targets: :x86_64},
      {:nerves_system_npi_imx6ull, "~> 0.2", runtime: false, targets: :npi_imx6ull},

      # local
      {:sgp40, path: "../sgp40"},
      {:kantan_cluster, path: "../kantan_cluster"}
    ]
  end

  def release do
    [
      overwrite: true,
      cookie: "#{@app}_cookie",
      include_erts: &Nerves.Release.erts/0,
      steps: [&Nerves.Release.init/1, :assemble],
      strip_beams: Mix.env() == :prod
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ~w[deps.get],
      format: ~w[format credo],
      test: ~w[format test],
      "prod.firmware": [&prod_firmware/1],
      "prod.upload": [&prod_upload/1]
    ]
  end

  defp prod_firmware(_args) do
    :ok = System.put_env([{"MIX_ENV", "prod"}])
    {_, 0} = System.cmd("mix", ["deps.get"], into: IO.stream(:stdio, :line))
    {_, 0} = System.cmd("mix", ["deps.compile"], into: IO.stream(:stdio, :line))
    {_, 0} = System.cmd("mix", ["firmware"], into: IO.stream(:stdio, :line))
  end

  defp prod_upload(_args) do
    :ok = System.put_env([{"MIX_ENV", "prod"}])
    {_, 0} = System.cmd("mix", ["upload"], into: IO.stream(:stdio, :line))
  end
end
