defmodule NervesEnvironmentSensor.Measurement do
  @moduledoc """
  One measurement from the senor.
  """

  defstruct [
    :altitude_m,
    :dew_point_c,
    :gas_resistance_ohms,
    :humidity_rh,
    :pressure_pa,
    :temperature_c,
    :time
  ]

  @type t :: %__MODULE__{
          altitude_m: number,
          dew_point_c: number,
          gas_resistance_ohms: number,
          humidity_rh: number,
          pressure_pa: number,
          temperature_c: number,
          time: number
        }
end
