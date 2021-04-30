defmodule HelloNerves.SensorApi do
  @moduledoc """
  Represents an external API that accepts sensor measurements.
  """

  @callback post_measurement(measurement()) :: {:ok, any} | {:error, any}

  @type measurement :: %{
          required(:humidity_rh) => number,
          required(:temperature_c) => number,
          required(:measured_at) => String.t(),
          optional(:dew_point_c) => number,
          optional(:gas_resistance_ohms) => number,
          optional(:pressure_pa) => number
        }
end
