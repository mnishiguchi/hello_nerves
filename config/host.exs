import Config

# Add configuration that is only needed when running on the host here.

# Use the mocks defined in test/support/mocks.ex
# https://hexdocs.pm/mox/Mox.html
config :hello_nerves,
  sensor_device_module: HelloNerves.MockSensorDevice,
  sensor_api_module: HelloNerves.MockSensorApi,
  sensor_api_url: System.fetch_env!("SENSOR_API_URL"),
  sensor_api_token: System.fetch_env!("SENSOR_API_TOKEN")
