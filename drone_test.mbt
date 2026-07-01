///|
/// Test drone status code constants.
test "drone status codes" {
  inspect(drone_status_idle(), content="0")
  inspect(drone_status_assigned(), content="1")
  inspect(drone_status_flying(), content="2")
  inspect(drone_status_returning(), content="3")
  inspect(drone_status_charging(), content="4")
  inspect(drone_status_fault(), content="5")
}

///|
/// Test drone status name conversion.
test "drone status names" {
  inspect(drone_status_name(drone_status_idle()), content="idle")
  inspect(drone_status_name(drone_status_assigned()), content="assigned")
  inspect(drone_status_name(drone_status_flying()), content="flying")
  inspect(drone_status_name(drone_status_returning()), content="returning")
  inspect(drone_status_name(drone_status_charging()), content="charging")
  inspect(drone_status_name(drone_status_fault()), content="fault")
  inspect(drone_status_name(999), content="unknown")
  inspect(drone_status_name(-1), content="unknown")
}

///|
/// Test battery clamp behavior.
test "clamp battery" {
  inspect(clamp_battery(-10), content="0")
  inspect(clamp_battery(0), content="0")
  inspect(clamp_battery(25), content="25")
  inspect(clamp_battery(100), content="100")
  inspect(clamp_battery(150), content="100")
}

///|
/// Test battery level classification.
test "battery level name" {
  inspect(battery_level_name(100), content="high")
  inspect(battery_level_name(80), content="high")
  inspect(battery_level_name(79), content="medium")
  inspect(battery_level_name(50), content="medium")
  inspect(battery_level_name(49), content="low")
  inspect(battery_level_name(25), content="low")
  inspect(battery_level_name(24), content="critical")
  inspect(battery_level_name(0), content="critical")

  // Values should be clamped before classification.
  inspect(battery_level_name(150), content="high")
  inspect(battery_level_name(-5), content="critical")
}

///|
/// Test takeoff battery threshold.
test "has takeoff battery" {
  inspect(has_takeoff_battery(100), content="true")
  inspect(has_takeoff_battery(30), content="true")
  inspect(has_takeoff_battery(29), content="false")
  inspect(has_takeoff_battery(0), content="false")
  inspect(has_takeoff_battery(-10), content="false")
  inspect(has_takeoff_battery(150), content="true")
}

///|
/// Test return-to-base safety rule.
test "should return to base" {
  // required = distance_to_base * 2 + 10
  // distance 10 requires 30 battery.
  inspect(should_return_to_base(31, 10), content="false")
  inspect(should_return_to_base(30, 10), content="true")
  inspect(should_return_to_base(29, 10), content="true")

  // distance 0 requires 10 battery.
  inspect(should_return_to_base(11, 0), content="false")
  inspect(should_return_to_base(10, 0), content="true")
  inspect(should_return_to_base(9, 0), content="true")

  // Battery should be clamped.
  inspect(should_return_to_base(150, 40), content="false")
  inspect(should_return_to_base(-5, 1), content="true")
}

///|
/// Test remaining flight step estimation.
test "estimate flight steps" {
  inspect(estimate_flight_steps(100), content="50")
  inspect(estimate_flight_steps(80), content="40")
  inspect(estimate_flight_steps(51), content="25")
  inspect(estimate_flight_steps(1), content="0")
  inspect(estimate_flight_steps(0), content="0")

  // Values should be clamped.
  inspect(estimate_flight_steps(150), content="50")
  inspect(estimate_flight_steps(-10), content="0")
}

///|
/// Test flight cost estimation.
test "estimate flight cost" {
  inspect(estimate_flight_cost(0), content="0")
  inspect(estimate_flight_cost(-10), content="0")
  inspect(estimate_flight_cost(1), content="2")
  inspect(estimate_flight_cost(10), content="20")
  inspect(estimate_flight_cost(50), content="100")
}

///|
/// Test battery after flight.
test "battery after flight" {
  inspect(battery_after_flight(100, 10), content="80")
  inspect(battery_after_flight(50, 10), content="30")
  inspect(battery_after_flight(20, 20), content="0")
  inspect(battery_after_flight(0, 10), content="0")

  // Non-positive distance should cost nothing.
  inspect(battery_after_flight(50, 0), content="50")
  inspect(battery_after_flight(50, -10), content="50")

  // Battery should be clamped after calculation.
  inspect(battery_after_flight(150, 10), content="100")
  inspect(battery_after_flight(-10, 10), content="0")
}

///|
/// Test payload allowance.
test "payload allowed" {
  inspect(payload_allowed(0, 10), content="true")
  inspect(payload_allowed(5, 10), content="true")
  inspect(payload_allowed(10, 10), content="true")
  inspect(payload_allowed(11, 10), content="false")
  inspect(payload_allowed(-1, 10), content="false")
}

///|
/// Test mission acceptance rule.
test "can accept mission" {
  inspect(can_accept_mission(drone_status_idle(), 100), content="true")
  inspect(can_accept_mission(drone_status_idle(), 30), content="true")
  inspect(can_accept_mission(drone_status_idle(), 29), content="false")

  inspect(can_accept_mission(drone_status_assigned(), 100), content="false")
  inspect(can_accept_mission(drone_status_flying(), 100), content="false")
  inspect(can_accept_mission(drone_status_returning(), 100), content="false")
  inspect(can_accept_mission(drone_status_charging(), 100), content="false")
  inspect(can_accept_mission(drone_status_fault(), 100), content="false")
}

///|
/// Test airborne status detection.
test "is airborne" {
  inspect(is_airborne(drone_status_idle()), content="false")
  inspect(is_airborne(drone_status_assigned()), content="false")
  inspect(is_airborne(drone_status_flying()), content="true")
  inspect(is_airborne(drone_status_returning()), content="true")
  inspect(is_airborne(drone_status_charging()), content="false")
  inspect(is_airborne(drone_status_fault()), content="false")
  inspect(is_airborne(999), content="false")
}

///|
/// Test operator attention rule.
test "needs attention" {
  inspect(needs_attention(drone_status_fault(), 100), content="true")
  inspect(needs_attention(drone_status_fault(), 0), content="true")

  inspect(needs_attention(drone_status_idle(), 24), content="true")
  inspect(needs_attention(drone_status_idle(), 0), content="true")
  inspect(needs_attention(drone_status_idle(), -10), content="true")

  inspect(needs_attention(drone_status_idle(), 25), content="false")
  inspect(needs_attention(drone_status_flying(), 80), content="false")
}

///|
/// Test inspection capacity estimation.
test "estimate inspection capacity" {
  inspect(estimate_inspection_capacity(100, 10), content="100")
  inspect(estimate_inspection_capacity(80, 10), content="80")
  inspect(estimate_inspection_capacity(80, 5), content="40")
  inspect(estimate_inspection_capacity(76, 8), content="60")
  inspect(estimate_inspection_capacity(0, 10), content="0")

  // Battery should be clamped.
  inspect(estimate_inspection_capacity(150, 10), content="100")
  inspect(estimate_inspection_capacity(-10, 10), content="0")

  // Sensor quality should be clamped to 1..10.
  inspect(estimate_inspection_capacity(80, 0), content="8")
  inspect(estimate_inspection_capacity(80, -5), content="8")
  inspect(estimate_inspection_capacity(80, 15), content="80")
}

///|
/// Test capacity level classification.
test "capacity level name" {
  inspect(capacity_level_name(100), content="excellent")
  inspect(capacity_level_name(80), content="excellent")
  inspect(capacity_level_name(79), content="good")
  inspect(capacity_level_name(50), content="good")
  inspect(capacity_level_name(49), content="limited")
  inspect(capacity_level_name(25), content="limited")
  inspect(capacity_level_name(24), content="poor")
  inspect(capacity_level_name(0), content="poor")
  inspect(capacity_level_name(-10), content="poor")
}
