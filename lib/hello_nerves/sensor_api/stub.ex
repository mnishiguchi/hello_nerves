defmodule HelloNerves.SensorApi.Stub do
  @moduledoc false

  @behaviour HelloNerves.SensorApi

  @impl HelloNerves.SensorApi
  def post_measurement(_measurement) do
    {:ok, fake_response()}
  end

  defp fake_response() do
    %{status_code: 201}
  end
end
