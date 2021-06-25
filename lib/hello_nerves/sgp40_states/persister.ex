defmodule HelloNerves.SGP40States.Persister do
  @moduledoc false

  use GenServer

  def start_link(_args) do
    GenServer.start_link(__MODULE__, nil, name: __MODULE__)
  end

  @impl GenServer
  def init(_args) do
    state = %{interval_ms: :timer.minutes(1)}
    {:ok, state, {:continue, :start_ticking}}
  end

  @impl GenServer
  def handle_continue(:start_ticking, state) do
    # Wait first interval instead of ticking immediately.
    Process.send_after(self(), :tick, state.interval_ms)
    {:noreply, state}
  end

  @impl GenServer
  def handle_info(:tick, state) do
    HelloNerves.SGP40States.save_states()
    Process.send_after(self(), :tick, state.interval_ms)
    {:noreply, state}
  end
end
