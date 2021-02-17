defmodule NervesEnvironmentSensor.Measurement do
  @moduledoc """
  One measurement from the senor. The basic structure is adopted from the
  [fhunleth/bmp280](https://github.com/fhunleth/bmp280) library.
  """

  @type t :: %{
          required(:humidity_rh) => number,
          required(:temperature_c) => number,
          optional(:altitude_m) => number,
          optional(:dew_point_c) => number,
          optional(:gas_resistance_ohms) => number,
          optional(:pressure_pa) => number,
          optional(:time) => String.t()
        }
end
