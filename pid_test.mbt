///|
test "pid_basic" {
  let pid = PID::new(1.0, 0.1, 0.05)
  let pid = PID::set_setpoint(pid, 10.0)
  let out = PID::update(pid, 0.0, 0.1)
  inspect(out > 0.0, content="true")
}
