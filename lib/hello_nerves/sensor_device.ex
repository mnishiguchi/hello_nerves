defmodule HelloNerves.SensorDevice do
  @moduledoc """
  Defines a behaviour required for an external sensor device.
  """

  alias HelloNerves.SensorApi

  @type options :: [{:bus_name, String.t()} | {:bus_address, 0..127}]

  @callback start_link(options) :: GenServer.on_start()
  @callback measure(pid) :: {:ok, SensorApi.measurement()} | {:error, any()}
end
