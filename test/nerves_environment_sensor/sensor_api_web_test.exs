defmodule NervesEnvironmentSensor.SensorApi.WebTest do
  use ExUnit.Case

  test "stringify measurement" do
    {:ok, measurement} = NervesEnvironmentSensor.SensorDevice.Stub.read(:c.pid(0, 0, 0))

    assert "{\"altitude_m\":99.80845853673719,\"dew_point_c\":1.8098743179175818,\"gas_resistance_ohms\":4358.471915520684,\"humidity_rh\":16.967493893888527,\"pressure_pa\":100720.59804120527,\"temperature_c\":29.437646528458572,\"time\":1612588426}" ==
             NervesEnvironmentSensor.SensorApi.Web.stringify_measurement(measurement)
  end
end
