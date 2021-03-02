defmodule NervesEnvironmentSensor.SensorDevice do
  @moduledoc """
  Defines a behaviour required for an external sensor device.
  """

  alias NervesEnvironmentSensor.SensorApi

  @type options :: [{:bus_name, String.t()} | {:bus_address, 0..127}]

  @callback start_link(options) :: GenServer.on_start()
  @callback measure(pid) :: {:ok, SensorApi.measurement()} | {:error, any()}
end

defmodule NervesEnvironmentSensor.SensorDevice.Stub do
  @moduledoc false
  @behaviour NervesEnvironmentSensor.SensorDevice

  @impl true
  def start_link(_opts), do: {:ok, fake_pid()}

  @impl true
  def measure(_pid), do: {:ok, fake_measurement()}

  defp fake_pid, do: :c.pid(0, 0, 0)

  defp fake_measurement do
    %{
      dew_point_c: 1.8098743179175818,
      gas_resistance_ohms: 4358.471915520684,
      humidity_rh: 16.967493893888527,
      pressure_pa: 100_720.59804120527,
      temperature_c: 29.437646528458572
    }
  end
end
