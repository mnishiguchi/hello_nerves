defmodule NervesEnvironmentSensor.SensorApi do
  @moduledoc """
  Represents an external API that accepts sensor measurements.
  """

  @callback post_measurement(measurement()) :: {:ok, any} | {:error, any}

  @type measurement :: %{
          required(:humidity_rh) => number,
          required(:temperature_c) => number,
          optional(:altitude_m) => number,
          optional(:dew_point_c) => number,
          optional(:gas_resistance_ohms) => number,
          optional(:pressure_pa) => number,
          optional(:measured_at) => String.t()
        }
end

defmodule NervesEnvironmentSensor.SensorApi.Web do
  @moduledoc false

  @behaviour NervesEnvironmentSensor.SensorApi

  @impl true
  def post_measurement(measurement) do
    measurement = Map.put(measurement, :measured_at, utc_now_iso8601())
    json = Jason.encode!(%{measurement: measurement})
    HTTPoison.post(endpoint_url(), json, [{"Content-Type", "application/json"}])
  end

  defp utc_now_iso8601, do: Timex.format!(Timex.now(), "{ISO:Extended}")
  defp endpoint_url, do: Application.fetch_env!(:nerves_environment_sensor, :sensor_api_url)
end

defmodule NervesEnvironmentSensor.SensorApi.Stub do
  @moduledoc false

  @behaviour NervesEnvironmentSensor.SensorApi

  @impl true
  def post_measurement(_measurement), do: {:ok, %{status_code: 201}}
end
