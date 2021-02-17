defmodule NervesEnvironmentSensor.SensorDevice.Stub do
  @moduledoc false
  @behaviour NervesEnvironmentSensor.SensorDevice

  @impl true
  def start_link(_opts), do: {:ok, fake_pid()}

  @impl true
  def read(_pid), do: {:ok, fake_measurement()}

  defp fake_pid, do: :c.pid(0, 0, 0)

  defp fake_measurement do
    %{
      altitude_m: 99.80845853673719,
      dew_point_c: 1.8098743179175818,
      gas_resistance_ohms: 4358.471915520684,
      humidity_rh: 16.967493893888527,
      pressure_pa: 100_720.59804120527,
      temperature_c: 29.437646528458572
    }
  end
end
