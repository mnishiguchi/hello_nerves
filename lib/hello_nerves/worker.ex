defmodule HelloNerves.Worker do
  @moduledoc """
  Repeats posting a sensor measurement to an external API.
  """

  use GenServer, restart: :temporary

  require Logger

  @type options() :: [
          bus_name: binary,
          bus_address: 0..127,
          interval_ms: pos_integer()
        ]

  @type state() :: %{
          bus_name: nil | binary,
          bus_address: nil | 0..127,
          interval_ms: pos_integer(),
          measurement: nil | HelloNerves.SensorApi.measurement() | %{error: any},
          sensor_pid: nil | pid
        }

  @default_interval_ms 1_000

  @spec start_link(options) :: GenServer.on_start()
  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  def whereis, do: Process.whereis(__MODULE__)
  def get_state, do: :sys.get_state(__MODULE__)
  def shutdown, do: Process.exit(whereis(), :shutdown)

  @impl GenServer
  def init(options) do
    # Interval and measurement do not have to be kept in the state but are nice to have for ease of testing.
    initial_state = %{
      bus_name: options[:bus_name],
      bus_address: options[:bus_address],
      interval_ms: options[:interval_ms] || @default_interval_ms,
      measurement: nil,
      sensor_pid: nil
    }

    {:ok, initial_state, {:continue, :init_sensor}}
  end

  @impl GenServer
  def handle_continue(:init_sensor, state) do
    {:ok, sensor_pid} = init_sensor(bus_name: state.bus_name, bus_address: state.bus_address)
    state = %{state | sensor_pid: sensor_pid}

    {:noreply, state, {:continue, :start_measurement}}
  end

  def handle_continue(:start_measurement, state) do
    state = read_sensor_and_post_measurement(state)
    Process.send_after(self(), :schedule_measurement, state.interval_ms)

    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:schedule_measurement, state) do
    state = read_sensor_and_post_measurement(state)
    Process.send_after(self(), :schedule_measurement, state.interval_ms)

    {:noreply, state}
  end

  @spec read_sensor_and_post_measurement(state) :: state
  def read_sensor_and_post_measurement(state) do
    case read_sensor(state.sensor_pid) do
      {:error, reason} ->
        Logger.error("Error reading sensor: #{reason}")
        %{state | measurement: %{error: reason}}

      {:ok, new_measurement} ->
        Logger.info("measurement: #{inspect(new_measurement)}")

        case post_measurement(new_measurement) do
          {:ok, %{status_code: 201}} ->
            Logger.info("Success posting measurement")
            %{state | measurement: new_measurement}

          {:ok, %{status_code: status_code}} ->
            reason = Plug.Conn.Status.reason_atom(status_code)
            Logger.error("Error posting measurement: #{reason}")
            %{state | measurement: %{error: reason}}

          {:error, %{reason: reason}} ->
            Logger.error("Error posting measurement: #{reason}")
            %{state | measurement: %{error: reason}}
        end
    end
  end

  defp init_sensor(opts), do: apply(sensor_device_module(), :start_link, [opts])
  defp read_sensor(sensor_pid), do: apply(sensor_device_module(), :measure, [sensor_pid])
  defp post_measurement(measurement), do: apply(sensor_api_module(), :post_measurement, [measurement])

  # https://hexdocs.pm/elixir/master/library-guidelines.html#avoid-compile-time-application-configuration
  defp sensor_device_module(), do: Application.fetch_env!(:hello_nerves, :sensor_device_module)
  defp sensor_api_module(), do: Application.fetch_env!(:hello_nerves, :sensor_api_module)
end
