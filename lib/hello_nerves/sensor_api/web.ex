defmodule HelloNerves.SensorApi.Web do
  @moduledoc false

  @behaviour HelloNerves.SensorApi

  @impl HelloNerves.SensorApi
  def post_measurement(measurement) when is_map(measurement) do
    body = Jason.encode!(%{measurement: measurement})
    res = %Req.Response{} = Req.post!(endpoint_url(), body, headers: req_headers())
    {:ok, res}
  rescue
    e -> {:error, e}
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
