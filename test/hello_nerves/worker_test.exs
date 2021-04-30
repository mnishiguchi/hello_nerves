defmodule HelloNerves.WorkerTest do
  use ExUnit.Case

  # https://hexdocs.pm/mox/Mox.html
  import Mox

  alias HelloNerves.{
    MockSensorApi,
    MockSensorDevice,
    SensorApi,
    SensorDevice,
    Worker
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
      assert {:ok, pid} = Worker.start_link(interval_ms: 5000)
      result1 = :sys.get_state(pid)

      assert %{
               interval_ms: 5000,
               measurement: %{
                 dew_point_c: 1.8098743179175818,
                 gas_resistance_ohms: 4358.471915520684,
                 humidity_rh: 16.967493893888527,
                 pressure_pa: 100_720.59804120527,
                 temperature_c: 29.437646528458572
               },
               sensor_pid: _
             } = result1
    end

    test "API bad request" do
      MockSensorApi
      |> Mox.expect(:post_measurement, 1, fn _measurement -> {:ok, %{status_code: 400}} end)

      assert {:ok, pid} = Worker.start_link()

      assert %{measurement: %{error: :bad_request}} = :sys.get_state(pid)
    end

    test "API connection error" do
      MockSensorApi
      |> Mox.expect(:post_measurement, 1, fn _measurement -> {:error, %{reason: :econnrefused}} end)

      assert {:ok, pid} = Worker.start_link()
      assert %{measurement: %{error: :econnrefused}} = :sys.get_state(pid)
    end
  end
end
