alias HelloNerves.Worker

import HelloNerves
import Mox

Mox.set_mox_from_context([])
Mox.stub_with(HelloNerves.MockSensorDevice, HelloNerves.SensorDevice.Stub)
Mox.stub_with(HelloNerves.MockSensorApi, HelloNerves.SensorApi.Stub)
