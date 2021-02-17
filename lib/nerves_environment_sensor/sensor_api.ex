defmodule NervesEnvironmentSensor.SensorApi do
  @moduledoc """
  Represents an external API that accepts sensor measurements.
  """

  @callback post_measurement(NervesEnvironmentSensor.Measurement.t()) :: {:ok, any} | {:error, any}
end

defmodule NervesEnvironmentSensor.SensorApi.V1 do
  @moduledoc false
  @behaviour NervesEnvironmentSensor.SensorApi

  @endpoint_url "https://example.com"

  @impl true
  def post_measurement(measurement) do
    # TODO: Implement API server
    # measurement
    # |> Jason.encode!()
    # |> HTTPoison.post(@endpoint_url)

    # This is a placeholder response
    {:ok, %{status_code: 200}}
  end
end

defmodule NervesEnvironmentSensor.SensorApi.Stub do
  @moduledoc false
  @behaviour NervesEnvironmentSensor.SensorApi

  @impl true
  def post_measurement(_measurement) do
    {:ok, %{status_code: 200}}
  end
end
