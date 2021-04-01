defmodule HelloNerves.SensorDevice.AHT20 do
  @moduledoc """
  Represents a AHT20 sensor. Implements the `HelloNerves.SensorDevice` behaviour.
  """

  alias HelloNerves.{SensorApi, SensorDevice}

  @behaviour SensorDevice

  @default_bus_name "i2c-1"
  @default_bus_address 0x38

  @impl true
  def start_link(opts \\ []) do
    bus_name = opts[:bus_name] || @default_bus_name
    bus_address = opts[:bus_address] || @default_bus_address

    AHT20.start_link(bus_name: bus_name, bus_address: bus_address)
  end

  @impl true
  def measure(pid) do
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
