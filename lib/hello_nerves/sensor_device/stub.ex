defmodule HelloNerves.SensorDevice.Stub do
  @moduledoc false

  @behaviour HelloNerves.SensorDevice

  @impl HelloNerves.SensorDevice
  def start_link(_opts) do
    {:ok, fake_pid()}
  end

  @impl HelloNerves.SensorDevice
  def measure(_pid) do
    {:ok, fake_measurement()}
  end

  defp fake_pid do
    :c.pid(0, 0, 0)
  end

  defp fake_measurement do
    %{
      dew_point_c: 1.8098743179175818,
      gas_resistance_ohms: 4358.471915520684,
      humidity_rh: 16.967493893888527,
      pressure_pa: 100_720.59804120527,
      temperature_c: 29.437646528458572,
      measured_at: "#{DateTime.utc_now()}"
    }
  end
end
