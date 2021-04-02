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

defmodule HelloNerves.SensorApi.Web do
  @moduledoc false

  @behaviour HelloNerves.SensorApi

  @impl true
  def post_measurement(measurement) do
    json = Jason.encode!(%{measurement: measurement})

    HTTPoison.post(endpoint_url(), json, req_headers())
  end

  defp req_headers do
    [
      {"Content-Type", "application/json"},
      {"Authorization", "Bearer " <> api_token()}
    ]
  end

  defp endpoint_url, do: Application.fetch_env!(:hello_nerves, :sensor_api_url)

  defp api_token, do: Application.fetch_env!(:hello_nerves, :mn_environment_api_token)
end

defmodule HelloNerves.SensorApi.Stub do
  @moduledoc false

  @behaviour HelloNerves.SensorApi

  @impl true
  def post_measurement(_measurement), do: {:ok, %{status_code: 201}}
end
