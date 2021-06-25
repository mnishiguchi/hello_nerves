defmodule HelloNerves.Worker do
  @moduledoc """
  Repeats posting a sensor measurement to an external API.
  """

  use GenServer, restart: :temporary

  require Logger

  @type options() :: [
          bus_name: binary,
          interval_ms: pos_integer()
        ]

  @type state() :: %{
          bus_name: nil | binary,
          interval_ms: pos_integer(),
          measurement: nil | HelloNerves.SensorApi.measurement() | %{error: any}
        }

  @default_interval_ms 1_000

  @spec start_link(options) :: GenServer.on_start()
  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  def whereis, do: Process.whereis(__MODULE__)

  def get_state, do: :sys.get_state(__MODULE__)

  def stop, do: Process.exit(whereis(), :normal)

  def shutdown, do: Process.exit(whereis(), :shutdown)

  @impl GenServer
  def init(options) do
    # Interval and measurement do not have to be kept in the state but are nice to have for ease of testing.
    initial_state = %{
      bus_name: options[:bus_name],
      interval_ms: options[:interval_ms] || @default_interval_ms,
      measurement: nil
    }

    {:ok, initial_state, {:continue, :init_sensors}}
  end

  @impl GenServer
  def handle_continue(:init_sensors, state) do
    Logger.info("[hello_nerves] Initializing sensors}")
    {:ok, _} = init_rht_sensor(bus_name: state.bus_name)
    {:ok, _} = init_sgp40(bus_name: state.bus_name)

    {:noreply, state, {:continue, :start_measurement}}
  end

  def handle_continue(:start_measurement, state) do
    state = read_sensors_and_post_measurement_and_update_state(state)
    Process.send_after(self(), :schedule_measurement, state.interval_ms)

    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:schedule_measurement, state) do
    state = read_sensors_and_post_measurement_and_update_state(state)
    Process.send_after(self(), :schedule_measurement, state.interval_ms)

    {:noreply, state}
  end

  @spec read_sensors_and_post_measurement_and_update_state(state) :: state
  def read_sensors_and_post_measurement_and_update_state(state) do
    case read_rht_sensor() do
      {:error, reason} ->
        Logger.error("[hello_nerves] Error reading sensor: #{reason}")
        %{state | measurement: %{error: reason}}

      {:ok, new_measurement} ->
        :ok = SGP40.update_rht(SGP40, new_measurement.humidity_rh, new_measurement.temperature_c)
        {:ok, %{voc_index: voc_index}} = SGP40.measure(SGP40)

        new_measurement
        # Inject voc index from SGP40 as IAQ
        |> Map.put(:iaq, voc_index)
        |> tap(fn x -> Logger.info("[hello_nerves] Posting measurement: #{inspect(x)}") end)
        |> post_measurement()
        |> api_response_to_state(new_measurement, state)
    end
  end

  defp api_response_to_state({:ok, %{status_code: 201}}, new_measurement, state) do
    Logger.info("[hello_nerves] Success posting measurement")

    %{state | measurement: new_measurement}
  end

  defp api_response_to_state({:ok, %{status_code: status_code}}, _, state) do
    reason = Plug.Conn.Status.reason_atom(status_code)
    Logger.error("[hello_nerves] Error posting measurement: #{reason}")

    %{state | measurement: %{error: reason}}
  end

  defp api_response_to_state({:error, %{reason: reason}}, _, state) do
    Logger.error("[hello_nerves] Error posting measurement: #{reason}")

    %{state | measurement: %{error: reason}}
  end

  defp init_rht_sensor(opts), do: apply(sensor_device_module(), :start_link, [opts])

  defp read_rht_sensor(), do: apply(sensor_device_module(), :measure, [])

  defp post_measurement(measurement), do: apply(sensor_api_module(), :post_measurement, [measurement])

  defp init_sgp40(opts) do
    result = {:ok, _} = SGP40.start_link(bus_name: opts[:bus_name], name: SGP40)
    HelloNerves.SGP40States.restore_states()
    result
  end

  # https://hexdocs.pm/elixir/master/library-guidelines.html#avoid-compile-time-application-configuration
  defp sensor_device_module(), do: Application.fetch_env!(:hello_nerves, :sensor_device_module)

  defp sensor_api_module(), do: Application.fetch_env!(:hello_nerves, :sensor_api_module)
end
