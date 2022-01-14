defmodule HelloNerves.Worker do
  @moduledoc """
  Repeats posting a sensor measurement to an external API.
  """

  use GenServer, restart: :transient

  require Logger

  @spec start_link(HelloNerves.options()) :: GenServer.on_start()
  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, options, name: __MODULE__)
  end

  @impl GenServer
  def init(options) do
    {:ok, HelloNerves.new(options), {:continue, :init_sensors}}
  end

  @impl GenServer
  def handle_continue(:init_sensors, state) do
    {:noreply, HelloNerves.init_sensors(state), {:continue, :start_measurement}}
  end

  @impl GenServer
  def handle_continue(:start_measurement, state) do
    send(self(), :schedule_measurement)

    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:schedule_measurement, state) do
    {:noreply, HelloNerves.schedule_measurement(state, self())}
  end
end
