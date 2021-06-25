defmodule HelloNerves.SensorDevice.AHT20 do
  @moduledoc false

  alias HelloNerves.{SensorApi, SensorDevice}

  @behaviour SensorDevice

  @impl HelloNerves.SensorDevice
  def start_link(opts \\ []) do
    bus_name = opts[:bus_name] || "i2c-1"

    AHT20.start_link(bus_name: bus_name, name: __MODULE__)
  end

  @impl HelloNerves.SensorDevice
  def measure(pid \\ __MODULE__) do
    case AHT20.measure(pid) do
      {:ok, measurement} -> {:ok, format_measurement(measurement)}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec format_measurement(map) :: SensorApi.measurement()
  def format_measurement(from_sensor) do
    %{
      humidity_rh: from_sensor.humidity_rh,
      temperature_c: from_sensor.temperature_c,
      measured_at: "#{DateTime.utc_now()}"
    }
  end
end
