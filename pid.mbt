// pid.mbt - 完整 PID 控制器

///|
pub struct PID {
  kp : Double
  ki : Double
  kd : Double
  setpoint : Double
  integral : Double
  prev_error : Double
}

///|
pub fn PID::new(kp : Double, ki : Double, kd : Double) -> PID {
  { kp, ki, kd, setpoint: 0.0, integral: 0.0, prev_error: 0.0 }
}

///|
pub fn PID::set_setpoint(self : PID, sp : Double) -> PID {
  {
    kp: self.kp,
    ki: self.ki,
    kd: self.kd,
    setpoint: sp,
    integral: 0.0, // 重置积分
    prev_error: 0.0, // 重置误差
  }
}

///|
pub fn PID::update(self : PID, measurement : Double, dt : Double) -> Double {
  let error = self.setpoint - measurement
  let p_term = self.kp * error

  let integral = self.integral + error * dt
  // 积分钳位，防止饱和
  let integral_clamped = if integral > 100.0 {
    100.0
  } else if integral < -100.0 {
    -100.0
  } else {
    integral
  }
  let i_term = self.ki * integral_clamped

  let derivative = if dt > 0.0 { (error - self.prev_error) / dt } else { 0.0 }
  let d_term = self.kd * derivative

  p_term + i_term + d_term
}
