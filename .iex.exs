import_file_if_available("~/.iex.exs")

if Code.ensure_loaded?(HelloNerves) do
  import_if_available(HelloNerves)
  import_if_available(Mox)

  Mox.set_mox_from_context([])
  Mox.stub_with(HelloNerves.MockSensorDevice, HelloNerves.SensorDevice.Stub)
  Mox.stub_with(HelloNerves.MockSensorApi, HelloNerves.SensorApi.Stub)
end
