defmodule SensorWorkerTest do
  use ExUnit.Case

  # https://hexdocs.pm/mox/Mox.html
  import Mox

  alias NervesEnvironmentSensor.{
    MockSensorApi,
    MockSensorDevice,
    SensorApi,
    SensorDevice,
    SensorWorker
  }

  # Any process can consume mocks and stubs defined in your tests.
  setup :set_mox_from_context

  # Make sure mocks are verified when the test exits
  setup :verify_on_exit!

  setup do
    Mox.stub_with(MockSensorDevice, SensorDevice.Stub)
    Mox.stub_with(MockSensorApi, SensorApi.Stub)
    :ok
  end

  describe "start_link" do
    test "has correct state" do
      interval = 123
      assert {:ok, pid} = SensorWorker.start_link(interval: interval)
      result1 = :sys.get_state(pid)

      assert %{
               interval: interval,
               measurement: %{
                 altitude_m: 99.80845853673719,
                 dew_point_c: 1.8098743179175818,
                 gas_resistance_ohms: 4358.471915520684,
                 humidity_rh: 16.967493893888527,
                 pressure_pa: 100_720.59804120527,
                 temperature_c: 29.437646528458572,
                 time: _
               },
               sensor_pid: _
             } = result1

      Process.sleep(interval)

      result2 = :sys.get_state(pid)
      refute result1.measurement.time == result2.measurement.time
    end
  end
end
