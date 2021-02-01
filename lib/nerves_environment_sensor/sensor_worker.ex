defmodule NervesEnvironmentSensor.SensorWorker do
  @moduledoc """
  Reads data from the sensor every 5 seconds.
  """

  use GenServer

  require Logger

  @interval :timer.seconds(5)
  @default_bus_name "i2c-1"
  @default_bus_address 0x77

  defmodule State do
    @moduledoc false
    defstruct [:interval, :measurement, :sensor_pid, :sensor_address]

    @type t :: %__MODULE__{
            interval: pos_integer(),
            measurement: NervesEnvironmentSensor.Measurement.t(),
            sensor_pid: pid,
            sensor_address: 0..127
          }
  end

  @spec whereis :: nil | pid | port
  def whereis do
    Process.whereis(__MODULE__)
  end

  @spec get_state :: map
  def get_state do
    :sys.get_state(__MODULE__)
  end

  def start_link(opts \\ []) do
    case GenServer.start_link(__MODULE__, opts, name: __MODULE__) do
      {:ok, pid} -> {:ok, pid}
      {:error, {:already_started, pid}} -> {:ok, pid}
      {:error, other_reason} -> {:error, other_reason}
    end
  end

  @impl true
  def init(opts \\ []) do
    # Parse options
    bus_name = opts[:bus_name] || @default_bus_name
    bus_address = opts[:bus_address] || @default_bus_address

    # Initialize the sensor
    {:ok, sensor_pid} = sensor_device_module().start_link(bus_name: bus_name, bus_address: bus_address)

    initial_state = %__MODULE__.State{
      interval: opts[:interval] || @interval,
      measurement: nil,
      sensor_pid: sensor_pid,
      sensor_address: bus_address
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

    # Read data from the sensor. Let it crash unless successful
    case sensor_device_module().read(sensor_pid) do
      {:ok, measurement} ->
        measurement
        |> log_measurement()
        |> sensor_api_module().post_measurement()
        |> case do
          {:ok, _response} -> {:noreply, %{state | measurement: measurement}}
          {:error, reason} -> raise reason
        end

      {:error, reason} ->
        raise reason
    end
  end

  @impl true
  def terminate(reason, _state) do
    Logger.error(inspect(reason))
  end

  defp log_measurement(measurement) do
    measurement |> Map.from_struct() |> inspect() |> Logger.info()
    measurement
  end

  # This enables us to switch the implementation with a mock.
  # https://hexdocs.pm/elixir/master/library-guidelines.html#avoid-compile-time-application-configuration
  defp sensor_device_module() do
    Application.get_env(:nerves_environment_sensor, :sensor_device_module, NervesEnvironmentSensor.SensorDevice.BME680)
  end

  defp sensor_api_module() do
    Application.get_env(:nerves_environment_sensor, :sensor_api_module, NervesEnvironmentSensor.SensorApi.Web)
  end
end
