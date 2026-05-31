// pid_test.mbt
test "pid_basic" {
    let mut pid = PID::new(1.0, 0.1, 0.05)
    pid.set_setpoint(10.0)
    let out = pid.update(0.0, 0.1)
    inspect(out, content="10")
}

test "pid_integral" {
    let mut pid = PID::new(1.0, 0.5, 0.0)
    pid.set_setpoint(10.0)
    let _ = pid.update(0.0, 0.1)
    let out2 = pid.update(5.0, 0.1)
    inspect(out2 > 10.0, content="true")
}