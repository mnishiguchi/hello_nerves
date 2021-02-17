defmodule NervesEnvironmentSensor.SensorWorker do
  @moduledoc """
  Reads data from the sensor every 5 seconds.
  """

  use GenServer

  require Logger

  @default_interval :timer.seconds(5)

  def whereis, do: Process.whereis(__MODULE__)

  def get_state, do: :sys.get_state(__MODULE__)

  def start_link(opts \\ []) do
    case GenServer.start_link(__MODULE__, opts, name: __MODULE__) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      {:error, other_reason} -> {:error, other_reason}
    end
  end

  @impl true
  def init(opts \\ []) do
    {:ok, sensor_pid} = initialize_sensor(bus_name: opts[:bus_name], bus_address: opts[:bus_address])

    initial_state = %{
      interval: opts[:interval] || @default_interval,
      measurement: nil,
      sensor_pid: sensor_pid
    }

    {:ok, initial_state, {:continue, :after_init}}
  end

  @impl true
  def handle_continue(:after_init, state) do
    send(self(), :schedule_measurement)
    {:noreply, state}
  end

  @impl true
  def handle_info(:schedule_measurement, %{sensor_pid: sensor_pid, interval: interval} = state) do
    Process.send_after(self(), :schedule_measurement, interval)

    case read_sensor(sensor_pid) do
      {:ok, new_measurement} ->
        new_measurement = Map.put(new_measurement, :time, utc_now_iso8601())

        new_measurement
        |> log_measurement()
        |> post_measurement()
        |> case do
          {:ok, _response} -> {:noreply, %{state | measurement: new_measurement}}
          {:error, _reason} -> Logger.error("Error posting measurement")
        end

      {:error, _reason} ->
        Logger.error("Error reading measurement")
    end
  end

  @impl true
  def terminate(reason, _state) do
    Logger.error("Stopping #{__MODULE__} #{inspect(reason)}")
  end

  defp initialize_sensor(opts) do
    sensor_device_module().start_link(opts)
  end

  defp read_sensor(sensor_pid) do
    sensor_device_module().read(sensor_pid)
  end

  defp post_measurement(measurement) do
    sensor_api_module().post_measurement(measurement)
  end

  defp log_measurement(measurement) do
    Logger.info(inspect(measurement))
    measurement
  end

  defp utc_now_iso8601 do
    Timex.format!(Timex.now(), "{ISO:Extended}")
  end

  # This enables us to switch the implementation with a mock.
  # https://hexdocs.pm/elixir/master/library-guidelines.html#avoid-compile-time-application-configuration
  defp sensor_device_module() do
    Application.fetch_env!(:nerves_environment_sensor, :sensor_device_module)
  end

  defp sensor_api_module() do
    Application.fetch_env!(:nerves_environment_sensor, :sensor_api_module)
  end
end
