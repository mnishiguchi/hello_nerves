# https://hexdocs.pm/mox/Mox.html#module-compile-time-requirements
Mox.defmock(HelloNerves.MockSensorDevice, for: HelloNerves.SensorDevice)
Mox.defmock(HelloNerves.MockSensorApi, for: HelloNerves.SensorApi)
