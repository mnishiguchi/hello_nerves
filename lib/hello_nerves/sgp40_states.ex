defmodule HelloNerves.SGP40States do
  @moduledoc false

  require Logger

  defmodule Record do
    @moduledoc false
    defstruct [:datetime, :states]
  end

  # The `set_states` feature should not be used after inerruptions of more than 10 minutes.
  @max_interruption_seconds 10 * 60

  @spec save_states :: :ok
  def save_states() do
    {:ok, algorithm_states} = SGP40.get_states()
    save_states(algorithm_states)
    :ok
  end

  def save_states(algorithm_states) do
    if valid?(algorithm_states) do
      Logger.info("[hello_nerves] Saving SGP40 algorithm states: #{inspect(algorithm_states)}")
      record = %Record{datetime: DateTime.utc_now(), states: algorithm_states}
      CubDB.put(CubDB, {__MODULE__, :algorithm_states}, record)
      :ok
    else
      invalid_states_error(algorithm_states)
    end
  end

  def restore_states do
    case CubDB.get(CubDB, {__MODULE__, :algorithm_states}) do
      nil ->
        :noop

      record ->
        restore_states_from_record(record)
        :ok
    end
  end

  defp restore_states_from_record(record) do
    if expired?(record) do
      Logger.info("[hello_nerves] SGP40 algorithm states in database is expired")
      :expired
    else
      if valid?(record.states) do
        Logger.info("[hello_nerves] Restoring SGP40 algorithm states: #{inspect(record.states)}")
        SGP40.set_states(record.states)
        CubDB.delete(CubDB, {__MODULE__, :algorithm_states})
        :ok
      else
        invalid_states_error(record.states)
      end
    end
  end

  defp invalid_states_error(algorithm_states) do
    Logger.error("[hello_nerves] Invalid SGP40 algorithm states: #{inspect(algorithm_states)}")
    {:error, "Invalid states: #{inspect(algorithm_states)}"}
  end

  defp valid?(algorithm_states) do
    case algorithm_states do
      %{mean: 0} -> false
      %{mean: _, std: _} -> true
      _ -> false
    end
  end

  defp expired?(record) do
    HelloNerves.DateTime.elapsed?(record.datetime, @max_interruption_seconds)
  end
end
