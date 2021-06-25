defmodule HelloNerves.DateTime do
  @moduledoc false

  @doc """
  ## Examples

      iex> then = DateTime.to_unix(~U[2021-01-01 00:00:00Z])
      iex> now = DateTime.to_unix(~U[2021-01-01 00:10:00Z])
      iex> elapsed_unix?(then, 10 * 60, now)
      false
      iex> elapsed_unix?(then, 10 * 60 - 1, now)
      true

  """
  def elapsed_unix?(unix_then, max_interval_seconds, unix_now \\ DateTime.to_unix(DateTime.utc_now()))
      when is_integer(unix_then) and is_integer(max_interval_seconds) and is_integer(unix_now) do
    unix_now - unix_then > max_interval_seconds
  end

  @doc """
  ## Examples

      iex> then = ~U[2021-01-01 00:00:00Z]
      iex> now = ~U[2021-01-01 00:10:00Z]
      iex> elapsed?(then, 10 * 60, now)
      false
      iex> elapsed?(then, 10 * 60 - 1, now)
      true

  """
  def elapsed?(datetime_then, max_interval_seconds, datetime_now \\ DateTime.utc_now())
      when is_struct(datetime_then) and is_integer(max_interval_seconds) and is_struct(datetime_now) do
    DateTime.diff(datetime_now, datetime_then) > max_interval_seconds
  end
end
