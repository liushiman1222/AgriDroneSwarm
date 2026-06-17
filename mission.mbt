///|
/// Mission model module for AgriDroneSwarm.
///
/// This module defines mission type, priority, workload,
/// assignment rules, and simple mission evaluation helpers.

///|
/// Crop inspection mission.
pub fn mission_type_inspection() -> Int {
  0
}

///|
/// Spraying mission.
pub fn mission_type_spraying() -> Int {
  1
}

///|
/// Mapping mission.
pub fn mission_type_mapping() -> Int {
  2
}

///|
/// Emergency mission.
pub fn mission_type_emergency() -> Int {
  3
}

///|
/// Charging mission.
pub fn mission_type_charging() -> Int {
  4
}

///|
/// Convert mission type to readable text.
pub fn mission_type_name(kind: Int) -> String {
  match kind {
    0 => "inspection"
    1 => "spraying"
    2 => "mapping"
    3 => "emergency"
    4 => "charging"
    _ => "unknown"
  }
}

///|
/// Low priority mission.
pub fn mission_priority_low() -> Int {
  1
}

///|
/// Normal priority mission.
pub fn mission_priority_normal() -> Int {
  2
}

///|
/// High priority mission.
pub fn mission_priority_high() -> Int {
  3
}

///|
/// Critical priority mission.
pub fn mission_priority_critical() -> Int {
  4
}

///|
/// Convert priority to readable text.
pub fn mission_priority_name(priority: Int) -> String {
  match priority {
    1 => "low"
    2 => "normal"
    3 => "high"
    4 => "critical"
    _ => "unknown"
  }
}

///|
/// Clamp mission priority into 1..4.
pub fn clamp_mission_priority(priority: Int) -> Int {
  if priority < 1 {
    1
  } else if priority > 4 {
    4
  } else {
    priority
  }
}

///|
/// Estimate mission workload from area and difficulty.
pub fn estimate_mission_workload(area: Int, difficulty: Int) -> Int {
  let safe_area = if area < 0 { 0 } else { area }
  let safe_difficulty = if difficulty < 1 {
    1
  } else if difficulty > 10 {
    10
  } else {
    difficulty
  }
  safe_area * safe_difficulty
}

///|
/// Estimate required battery for a mission.
pub fn estimate_required_battery(distance: Int, workload: Int) -> Int {
  let safe_distance = if distance < 0 { 0 } else { distance }
  let safe_workload = if workload < 0 { 0 } else { workload }
  safe_distance * 2 + safe_workload / 10 + 10
}

///|
/// Check whether a mission is urgent.
pub fn is_urgent_mission(priority: Int, kind: Int) -> Bool {
  clamp_mission_priority(priority) >= mission_priority_high() ||
  kind == mission_type_emergency()
}

///|
/// Check whether a mission needs payload.
pub fn mission_needs_payload(kind: Int) -> Bool {
  kind == mission_type_spraying()
}

///|
/// Check whether a mission can be done without payload.
pub fn mission_allows_empty_payload(kind: Int) -> Bool {
  !mission_needs_payload(kind)
}

///|
/// Estimate mission score.
///
/// Higher priority and lower workload produce better score.
pub fn mission_score(priority: Int, workload: Int) -> Int {
  let safe_priority = clamp_mission_priority(priority)
  let safe_workload = if workload < 0 { 0 } else { workload }
  safe_priority * 100 - safe_workload / 10
}

///|
/// Check whether a drone battery is enough for a mission.
pub fn mission_battery_sufficient(battery: Int, required: Int) -> Bool {
  clamp_battery(battery) >= required
}

///|
/// Check whether a drone can be assigned to a mission.
pub fn can_assign_mission(
  drone_status: Int,
  battery: Int,
  mission_kind: Int,
  required_battery: Int,
  payload: Int,
  max_payload: Int
) -> Bool {
  let base_ok = can_accept_mission(drone_status, battery)
  let battery_ok = mission_battery_sufficient(battery, required_battery)
  let payload_ok = if mission_needs_payload(mission_kind) {
    payload_allowed(payload, max_payload)
  } else {
    true
  }
  base_ok && battery_ok && payload_ok
}

///|
/// Convert workload to readable level.
pub fn workload_level_name(workload: Int) -> String {
  if workload >= 800 {
    "heavy"
  } else if workload >= 400 {
    "medium"
  } else if workload >= 100 {
    "light"
  } else {
    "tiny"
  }
}

///|
/// Estimate number of drones needed for a mission.
pub fn estimate_required_drones(workload: Int) -> Int {
  if workload <= 0 {
    1
  } else if workload <= 300 {
    1
  } else if workload <= 700 {
    2
  } else if workload <= 1200 {
    3
  } else {
    4
  }
}

///|
/// Check whether mission can be handled by available drones.
pub fn enough_drones_for_mission(available: Int, workload: Int) -> Bool {
  available >= estimate_required_drones(workload)
}

///|
/// Estimate mission completion time.
pub fn estimate_completion_time(workload: Int, drone_count: Int) -> Int {
  let safe_workload = if workload < 0 { 0 } else { workload }
  let safe_drones = if drone_count <= 0 { 1 } else { drone_count }
  safe_workload / safe_drones + 5
}

///|
/// Check whether mission is suitable for immediate dispatch.
pub fn ready_for_dispatch(
  available_drones: Int,
  workload: Int,
  battery: Int,
  required_battery: Int
) -> Bool {
  enough_drones_for_mission(available_drones, workload) &&
  mission_battery_sufficient(battery, required_battery)
}

///|
/// Mission module demo.
pub fn mission_summary() -> Unit {
  let kind = mission_type_inspection()
  let priority = mission_priority_high()
  let workload = estimate_mission_workload(60, 6)
  let required_battery = estimate_required_battery(12, workload)

  println("Mission module:")
  println("- Mission types: inspection, spraying, mapping, emergency, charging")
  println("- Priority levels: low, normal, high, critical")
  println("- Assignment rule: idle drone + enough battery + payload check")
  println("- Example mission type:")
  println(mission_type_name(kind))
  println("- Example priority:")
  println(mission_priority_name(priority))
  println("- Example workload level:")
  println(workload_level_name(workload))
  println("- Required battery:")
  println(required_battery.to_string())
  println("- Required drones:")
  println(estimate_required_drones(workload).to_string())
}
