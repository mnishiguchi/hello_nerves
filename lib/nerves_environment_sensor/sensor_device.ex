defmodule NervesEnvironmentSensor.SensorDevice do
  @moduledoc """
  Defines a behaviour required for an external sensor device.
  """

  @type options :: [{:bus_name, String.t()} | {:bus_address, 0..127}]

  @callback start_link(options) :: GenServer.on_start()
  @callback read(pid) :: {:ok, %NervesEnvironmentSensor.Measurement{}} | {:error, any()}
end

defmodule NervesEnvironmentSensor.SensorDevice.BME680 do
  @moduledoc """
  Represents a BME680 sensor. Implements the `NervesEnvironmentSensor.SensorDevice` behaviour.
  """
  @behaviour NervesEnvironmentSensor.SensorDevice

  @default_bus_name "i2c-1"
  @default_bus_address 0x77

  @impl true
  def start_link(opts \\ []) do
    bus_name = opts[:bus_name] || @default_bus_name
    bus_address = opts[:bus_address] || @default_bus_address

    BMP280.start_link(bus_name: bus_name, bus_address: bus_address)
  end

  @impl true
  def read(pid) do
    case BMP280.read(pid) do
      {:ok, measurement} -> {:ok, format_measurement(measurement)}
      {:error, reason} -> {:error, reason}
    end
  end

  @spec format_measurement(map) :: NervesEnvironmentSensor.Measurement.t()
  def format_measurement(from_sensor) do
    %NervesEnvironmentSensor.Measurement{
      altitude_m: from_sensor.altitude_m,
      dew_point_c: from_sensor.dew_point_c,
      gas_resistance_ohms: from_sensor.gas_resistance_ohms,
      pressure_pa: from_sensor.pressure_pa,
      humidity_rh: from_sensor.humidity_rh,
      temperature_c: from_sensor.temperature_c,
      time: Timex.to_unix(Timex.now())
    }
  end
end

defmodule NervesEnvironmentSensor.SensorDevice.Stub do
  @moduledoc false
  @behaviour NervesEnvironmentSensor.SensorDevice

  @impl true
  def start_link(_opts) do
    {:ok, :c.pid(0, 0, 0)}
  end

  @impl true
  def read(_pid) do
    {:ok, fake_measurement()}
  end

  defp fake_measurement do
    %NervesEnvironmentSensor.Measurement{
      altitude_m: 99.80845853673719,
      dew_point_c: 1.8098743179175818,
      gas_resistance_ohms: 4358.471915520684,
      humidity_rh: 16.967493893888527,
      pressure_pa: 100_720.59804120527,
      temperature_c: 29.437646528458572,
      time: 1_612_588_426
    }
  end
end
