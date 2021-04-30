defmodule HelloNerves.SensorDevice.BME680 do
  @moduledoc false

  alias HelloNerves.{SensorApi, SensorDevice}

  @behaviour SensorDevice

  @default_bus_name "i2c-1"
  @default_bus_address 0x77

  @impl HelloNerves.SensorDevice
  def start_link(opts \\ []) do
    bus_name = opts[:bus_name] || @default_bus_name
    bus_address = opts[:bus_address] || @default_bus_address

    BMP280.start_link(bus_name: bus_name, bus_address: bus_address)
  end

  @impl HelloNerves.SensorDevice
  def measure(pid) do
    case BMP280.measure(pid) do
      {:ok, measurement} -> {:ok, format_measurement(measurement)}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec format_measurement(map) :: SensorApi.measurement()
  def format_measurement(from_sensor) do
    %{
      dew_point_c: from_sensor.dew_point_c,
      gas_resistance_ohms: from_sensor.gas_resistance_ohms,
      pressure_pa: from_sensor.pressure_pa,
      humidity_rh: from_sensor.humidity_rh,
      temperature_c: from_sensor.temperature_c,
      measured_at: "#{DateTime.utc_now()}"
    }
  end
end
