defmodule HelloNerves.SensorApi do
  @moduledoc """
  Represents an external API that accepts sensor measurements.
  """

  @callback post_measurement(measurement()) :: {:ok, any} | {:error, any}

  @type measurement :: %{
          required(:humidity_rh) => number,
          required(:temperature_c) => number,
          required(:measured_at) => String.t(),
          optional(:iaq) => number,
          optional(:dew_point_c) => number,
          optional(:pressure_pa) => number,
          optional(:__struct__) => atom
        }
end
