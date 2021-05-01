defmodule HelloNerves.SensorApi.Web do
  @moduledoc false

  @behaviour HelloNerves.SensorApi

  @impl HelloNerves.SensorApi
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

  defp api_token, do: Application.fetch_env!(:hello_nerves, :sensor_api_token)
end
