// pid.mbt - PID 控制器

pub struct PID {
    kp: Double
    ki: Double
    kd: Double
    mut setpoint: Double
    mut integral: Double
    mut prev_error: Double
}

pub fn PID::new(kp: Double, ki: Double, kd: Double) -> PID {
    {
        kp: kp,
        ki: ki,
        kd: kd,
        setpoint: 0.0,
        integral: 0.0,
        prev_error: 0.0,
    }
}

pub fn PID::set_setpoint(mut self, setpoint: Double) -> Unit {
    self.setpoint = setpoint
}

pub fn PID::reset(mut self) -> Unit {
    self.integral = 0.0
    self.prev_error = 0.0
}

pub fn PID::update(mut self, measurement: Double, dt: Double) -> Double {
    let error = self.setpoint - measurement
    let p_term = self.kp * error
    self.integral += error * dt
    if self.integral > 100.0 { self.integral = 100.0 }
    if self.integral < -100.0 { self.integral = -100.0 }
    let i_term = self.ki * self.integral
    let derivative = (error - self.prev_error) / dt
    let d_term = self.kd * derivative
    self.prev_error = error
    p_term + i_term + d_term
}