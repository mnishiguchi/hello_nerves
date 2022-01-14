defmodule HelloNerves do
  @moduledoc false

  require Logger

  @type options() :: [
          bus_name: binary,
          interval_ms: pos_integer()
        ]

  @type t() :: %{
          bus_name: nil | binary,
          interval_ms: pos_integer(),
          measurement: nil | HelloNerves.SensorApi.measurement() | %{error: any}
        }

  @default_interval_ms 1_000
  @log_prefix "HelloNerves: "

  @spec new(options()) :: t()
  def new(options \\ []) do
    # Interval and measurement do not have to be kept in the state but are nice to have for ease of testing.
    %{
      bus_name: options[:bus_name],
      interval_ms: options[:interval_ms] || @default_interval_ms,
      measurement: nil
    }
  end

  @spec init_sensors(t()) :: t() | no_return()
  def init_sensors(state) do
    Logger.info("#{@log_prefix} Initializing sensors}")
    {:ok, _} = sensor_device_mod().start_link(bus_name: state.bus_name)
    {:ok, _} = HelloNerves.SGP40Device.start_link(bus_name: state.bus_name)
    state
  end

  @spec schedule_measurement(t(), pid()) :: t()
  def schedule_measurement(state, server) when is_pid(server) do
    state = read_sensors_and_post_measurement_and_update_state(state)
    Process.send_after(server, :schedule_measurement, state.interval_ms)
    state
  end

  @spec read_sensors_and_post_measurement_and_update_state(t()) :: t()
  defp read_sensors_and_post_measurement_and_update_state(state) do
    case sensor_device_mod().measure() do
      {:error, reason} ->
        Logger.error("#{@log_prefix} Error reading sensor: #{reason}")
        %{state | measurement: %{error: reason}}

      {:ok, new_measurement} ->
        voc_index =
          HelloNerves.SGP40Device.measure!(
            new_measurement.humidity_rh,
            new_measurement.temperature_c
          )

        new_measurement
        # Inject voc index from SGP40 as IAQ
        |> Map.put(:iaq, voc_index)
        |> tap(fn x -> Logger.info("#{@log_prefix} Posting measurement: #{inspect(x)}") end)
        |> broadcast_measurement()
        |> sensor_api_mod().post_measurement()
        |> case do
          {:ok, %{status: 201}} ->
            Logger.info("#{@log_prefix} Success posting measurement")
            %{state | measurement: new_measurement}

          {:ok, %{status: status}} ->
            reason = Plug.Conn.Status.reason_atom(status)
            Logger.error("#{@log_prefix} Error posting measurement: #{inspect(reason)}")
            %{state | measurement: %{error: reason}}

          {:error, reason} ->
            Logger.error("#{@log_prefix} Error posting measurement: #{inspect(reason)}")
            %{state | measurement: %{error: reason}}
        end
    end
  end

  @spec broadcast_measurement(map()) :: map()
  defp broadcast_measurement(measurement) when is_map(measurement) do
    msg = {:hello_nerves_measurement, measurement, node()}
    :ok = KantanCluster.broadcast("hello_nerves:measurements", msg)
    measurement
  end

  defp sensor_device_mod(), do: Application.fetch_env!(:hello_nerves, :sensor_device_module)

  defp sensor_api_mod(), do: Application.fetch_env!(:hello_nerves, :sensor_api_module)
end
