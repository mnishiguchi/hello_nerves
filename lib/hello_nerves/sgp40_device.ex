defmodule HelloNerves.SGP40Device do
  @moduledoc false

  @spec start_link(bus_name: binary()) :: GenServer.on_start()
  def start_link(opts \\ []) do
    bus_name = Access.fetch!(opts, :bus_name)
    result = SGP40.start_link(bus_name: bus_name, name: __MODULE__)
    HelloNerves.SGP40States.restore_states()
    result
  end

  def measure!(pid \\ __MODULE__, humidity_rh, temperature_c) do
    :ok = SGP40.update_rht(__MODULE__, humidity_rh, temperature_c)
    {:ok, %{voc_index: voc_index}} = SGP40.measure(__MODULE__)
    voc_index
  end
end
