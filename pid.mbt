pub struct PID {
  kp: Double
  ki: Double
  kd: Double
  setpoint: Double
  prev_error: Double
  integral: Double
}

pub fn PID::new(kp: Double, ki: Double, kd: Double) -> PID {
  {
    kp: kp,
    ki: ki,
    kd: kd,
    setpoint: 0.0,
    prev_error: 0.0,
    integral: 0.0,
  }
}

pub fn PID::set_setpoint(self: PID, sp: Double) -> PID {
  {
    kp: self.kp,
    ki: self.ki,
    kd: self.kd,
    setpoint: sp,
    prev_error: self.prev_error,
    integral: self.integral,
  }
}

pub fn PID::update(self: PID, measurement: Double) -> Double {
  let error = self.setpoint - measurement
  error
}
