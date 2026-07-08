///|
/// Drone model module for AgriDroneSwarm.
///
/// This file defines simple drone state, battery, payload,
/// safety, and capability helper functions.

///|
/// Idle drone status code.
pub fn drone_status_idle() -> Int {
  0
}

///|
/// Assigned drone status code.
pub fn drone_status_assigned() -> Int {
  1
}

///|
/// Flying drone status code.
pub fn drone_status_flying() -> Int {
  2
}

///|
/// Returning drone status code.
pub fn drone_status_returning() -> Int {
  3
}

///|
/// Charging drone status code.
pub fn drone_status_charging() -> Int {
  4
}

///|
/// Fault drone status code.
pub fn drone_status_fault() -> Int {
  5
}

///|
/// Convert drone status code to readable text.
pub fn drone_status_name(status : Int) -> String {
  match status {
    0 => "idle"
    1 => "assigned"
    2 => "flying"
    3 => "returning"
    4 => "charging"
    5 => "fault"
    _ => "unknown"
  }
}

///|
/// Clamp battery percentage into 0..100.
pub fn clamp_battery(value : Int) -> Int {
  if value < 0 {
    0
  } else if value > 100 {
    100
  } else {
    value
  }
}

///|
/// Classify battery level.
pub fn battery_level_name(battery : Int) -> String {
  let safe_battery = clamp_battery(battery)
  if safe_battery >= 80 {
    "high"
  } else if safe_battery >= 50 {
    "medium"
  } else if safe_battery >= 25 {
    "low"
  } else {
    "critical"
  }
}

///|
/// Check whether a drone has enough battery to take off.
pub fn has_takeoff_battery(battery : Int) -> Bool {
  clamp_battery(battery) >= 30
}

///|
/// Check whether a drone should return to base.
pub fn should_return_to_base(battery : Int, distance_to_base : Int) -> Bool {
  let safe_battery = clamp_battery(battery)
  let required = distance_to_base * 2 + 10
  safe_battery <= required
}

///|
/// Estimate remaining flight steps from battery.
pub fn estimate_flight_steps(battery : Int) -> Int {
  clamp_battery(battery) / 2
}

///|
/// Estimate battery cost for a flight distance.
pub fn estimate_flight_cost(distance : Int) -> Int {
  if distance <= 0 {
    0
  } else {
    distance * 2
  }
}

///|
/// Estimate battery after flight.
pub fn battery_after_flight(battery : Int, distance : Int) -> Int {
  clamp_battery(battery - estimate_flight_cost(distance))
}

///|
/// Check whether payload weight is acceptable.
pub fn payload_allowed(payload : Int, max_payload : Int) -> Bool {
  if payload < 0 {
    false
  } else {
    payload <= max_payload
  }
}

///|
/// Check whether a drone can accept a new mission.
pub fn can_accept_mission(status : Int, battery : Int) -> Bool {
  if status == drone_status_idle() {
    has_takeoff_battery(battery)
  } else {
    false
  }
}

///|
/// Check whether a drone is currently active in the air.
pub fn is_airborne(status : Int) -> Bool {
  status == drone_status_flying() || status == drone_status_returning()
}

///|
/// Check whether a drone requires operator attention.
pub fn needs_attention(status : Int, battery : Int) -> Bool {
  if status == drone_status_fault() {
    true
  } else {
    battery_level_name(battery) == "critical"
  }
}

///|
/// Estimate inspection capacity based on battery and sensor quality.
pub fn estimate_inspection_capacity(battery : Int, sensor_quality : Int) -> Int {
  let safe_battery = clamp_battery(battery)
  let safe_quality = if sensor_quality < 1 {
    1
  } else if sensor_quality > 10 {
    10
  } else {
    sensor_quality
  }
  safe_battery * safe_quality / 10
}

///|
/// Convert capacity score to readable level.
pub fn capacity_level_name(capacity : Int) -> String {
  if capacity >= 80 {
    "excellent"
  } else if capacity >= 50 {
    "good"
  } else if capacity >= 25 {
    "limited"
  } else {
    "poor"
  }
}

///|
/// Simple drone module demo.
pub fn drone_summary() -> Unit {
  println("Drone module:")
  println("- Status model: idle, assigned, flying, returning, charging, fault")
  println("- Battery model: high, medium, low, critical")
  println("- Safety rule: return before battery becomes insufficient")
  println(
    "- Mission rule: only idle drones with enough battery can accept tasks",
  )
  println("- Example status:")
  println(drone_status_name(drone_status_idle()))
  println("- Example battery level:")
  println(battery_level_name(76))
  println("- Example capacity level:")
  println(capacity_level_name(estimate_inspection_capacity(76, 8)))
}
