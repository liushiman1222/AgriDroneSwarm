test "pid_error_positive" {
  let pid = PID::new(1.0, 0.0, 0.0).set_setpoint(10.0)
  inspect(pid.update(3.0), content="7")
}

test "pid_error_negative" {
  let pid = PID::new(1.0, 0.0, 0.0).set_setpoint(2.0)
  inspect(pid.update(5.0), content="-3")
}

test "pid_error_zero" {
  let pid = PID::new(1.0, 0.0, 0.0).set_setpoint(4.0)
  inspect(pid.update(4.0), content="0")
}
