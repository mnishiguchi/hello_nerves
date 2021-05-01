defmodule HelloNerves.MixProject do
  use Mix.Project

  @app :hello_nerves
  @version "0.1.0"
  @all_targets [:rpi, :rpi0, :rpi2, :rpi3, :rpi3a, :rpi4, :bbb, :osd32mp1, :x86_64]

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
      # {:bmp280, github: "mnishiguchi/bmp280", branch: "mnishiguchi/main"},
      {:bmp280, "~> 0.2"},
      {:elixir_bme680, "~> 0.2"},
      {:httpoison, "~> 1.8"},
      {:jason, "~> 1.2"},
      {:aht20, github: "mnishiguchi/aht20", branch: "main"},
      {:plug, "~> 1.7"},
      {:i2c_server, "~> 0.2"},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:mox, "~> 1.0.0", only: [:dev, :test]},

      # Dependencies for all targets except :host
      {:nerves_runtime, "~> 0.11.3", targets: @all_targets},
      {:nerves_pack, "~> 0.4.0", targets: @all_targets},

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
      {:nerves_system_npi_imx6ull, "~> 0.2", runtime: false, targets: :npi_imx6ull}
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
      test: ~w[format credo test dialyzer],
      deploy: ~w[firmware upload]
    ]
  end
end
