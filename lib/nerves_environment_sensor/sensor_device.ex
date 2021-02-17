defmodule NervesEnvironmentSensor.SensorDevice do
  @moduledoc """
  Defines a behaviour required for an external sensor device.
  """

  @type options :: [{:bus_name, String.t()} | {:bus_address, 0..127}]

  @callback start_link(options) :: GenServer.on_start()
  @callback read(pid) :: {:ok, map} | {:error, any()}
end
