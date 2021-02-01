import Config

# Add configuration that is only needed when running on the host here.

# Use the mocks defined in test/support/mocks.ex
# https://hexdocs.pm/mox/Mox.html
config :nerves_environment_sensor,
  sensor_device_module: NervesEnvironmentSensor.MockSensorDevice,
  sensor_api_module: NervesEnvironmentSensor.MockSensorApi
