///|
/// Maintenance module for AgriDroneSwarm.
///
/// This module provides simple maintenance state,
/// fault severity, service priority, and repair-time helpers.

///|
/// Maintenance state: healthy.
pub fn maintenance_state_healthy() -> Int {
  0
}

///|
/// Maintenance state: warning.
pub fn maintenance_state_warning() -> Int {
  1
}

///|
/// Maintenance state: service required.
pub fn maintenance_state_service_required() -> Int {
  2
}

///|
/// Maintenance state: grounded.
pub fn maintenance_state_grounded() -> Int {
  3
}

///|
/// Maintenance state: retired.
pub fn maintenance_state_retired() -> Int {
  4
}

///|
/// Convert maintenance state to readable text.
pub fn maintenance_state_name(state : Int) -> String {
  match state {
    0 => "healthy"
    1 => "warning"
    2 => "service-required"
    3 => "grounded"
    4 => "retired"
    _ => "unknown"
  }
}

///|
/// Fault type: none.
pub fn maintenance_fault_none() -> Int {
  0
}

///|
/// Fault type: battery.
pub fn maintenance_fault_battery() -> Int {
  1
}

///|
/// Fault type: motor.
pub fn maintenance_fault_motor() -> Int {
  2
}

///|
/// Fault type: propeller.
pub fn maintenance_fault_propeller() -> Int {
  3
}

///|
/// Fault type: sensor.
pub fn maintenance_fault_sensor() -> Int {
  4
}

///|
/// Fault type: communication.
pub fn maintenance_fault_communication() -> Int {
  5
}

///|
/// Fault type: navigation.
pub fn maintenance_fault_navigation() -> Int {
  6
}

///|
/// Convert fault type to readable text.
pub fn maintenance_fault_name(fault : Int) -> String {
  match fault {
    0 => "none"
    1 => "battery"
    2 => "motor"
    3 => "propeller"
    4 => "sensor"
    5 => "communication"
    6 => "navigation"
    _ => "unknown"
  }
}

///|
/// Clamp score into 0..100.
pub fn maintenance_clamp_score(value : Int) -> Int {
  if value < 0 {
    0
  } else if value > 100 {
    100
  } else {
    value
  }
}

///|
/// Clamp count into non-negative range.
pub fn maintenance_clamp_count(value : Int) -> Int {
  if value < 0 {
    0
  } else {
    value
  }
}

///|
/// Clamp minutes into non-negative range.
pub fn maintenance_clamp_minutes(value : Int) -> Int {
  if value < 0 {
    0
  } else {
    value
  }
}

///|
/// Estimate battery wear score.
pub fn maintenance_battery_wear_score(
  cycle_count : Int,
  battery_health : Int,
) -> Int {
  let cycles = maintenance_clamp_count(cycle_count)
  let health = maintenance_clamp_score(battery_health)
  let cycle_penalty = if cycles >= 800 {
    45
  } else if cycles >= 500 {
    30
  } else if cycles >= 250 {
    15
  } else {
    5
  }
  maintenance_clamp_score(cycle_penalty + (100 - health) / 2)
}

///|
/// Estimate motor wear score.
pub fn maintenance_motor_wear_score(
  flight_hours : Int,
  vibration_score : Int,
) -> Int {
  let hours = maintenance_clamp_count(flight_hours)
  let vibration = maintenance_clamp_score(vibration_score)
  let hour_penalty = if hours >= 1000 {
    45
  } else if hours >= 600 {
    30
  } else if hours >= 300 {
    18
  } else {
    6
  }
  maintenance_clamp_score(hour_penalty + vibration / 2)
}

///|
/// Estimate propeller wear score.
pub fn maintenance_propeller_wear_score(
  flight_hours : Int,
  impact_count : Int,
) -> Int {
  let hours = maintenance_clamp_count(flight_hours)
  let impacts = maintenance_clamp_count(impact_count)
  let hour_penalty = if hours >= 300 {
    40
  } else if hours >= 150 {
    25
  } else if hours >= 60 {
    12
  } else {
    4
  }
  maintenance_clamp_score(hour_penalty + impacts * 8)
}

///|
/// Estimate sensor wear score.
pub fn maintenance_sensor_wear_score(
  dust_level : Int,
  calibration_age_days : Int,
) -> Int {
  let dust = maintenance_clamp_score(dust_level)
  let age = maintenance_clamp_count(calibration_age_days)
  let age_penalty = if age >= 180 {
    40
  } else if age >= 90 {
    25
  } else if age >= 30 {
    10
  } else {
    2
  }
  maintenance_clamp_score(dust / 2 + age_penalty)
}

///|
/// Estimate communication wear score.
pub fn maintenance_comm_wear_score(
  packet_loss_percent : Int,
  reconnect_count : Int,
) -> Int {
  let loss = maintenance_clamp_score(packet_loss_percent)
  let reconnect = maintenance_clamp_count(reconnect_count)
  maintenance_clamp_score(loss * 2 + reconnect * 5)
}

///|
/// Estimate navigation wear score.
pub fn maintenance_navigation_wear_score(
  gps_error_meters : Int,
  compass_drift : Int,
) -> Int {
  let gps = maintenance_clamp_count(gps_error_meters)
  let drift = maintenance_clamp_score(compass_drift)
  maintenance_clamp_score(gps * 4 + drift)
}

///|
/// Convert wear score to maintenance state.
pub fn maintenance_state_from_wear(wear_score : Int) -> Int {
  let score = maintenance_clamp_score(wear_score)
  if score >= 85 {
    maintenance_state_grounded()
  } else if score >= 65 {
    maintenance_state_service_required()
  } else if score >= 35 {
    maintenance_state_warning()
  } else {
    maintenance_state_healthy()
  }
}

///|
/// Convert wear score to readable level.
pub fn maintenance_wear_level_name(wear_score : Int) -> String {
  let score = maintenance_clamp_score(wear_score)
  if score >= 85 {
    "critical"
  } else if score >= 65 {
    "high"
  } else if score >= 35 {
    "medium"
  } else {
    "low"
  }
}

///|
/// Estimate total maintenance risk score.
pub fn maintenance_total_risk_score(
  battery_wear : Int,
  motor_wear : Int,
  propeller_wear : Int,
  sensor_wear : Int,
  comm_wear : Int,
  navigation_wear : Int,
) -> Int {
  let battery = maintenance_clamp_score(battery_wear)
  let motor = maintenance_clamp_score(motor_wear)
  let propeller = maintenance_clamp_score(propeller_wear)
  let sensor = maintenance_clamp_score(sensor_wear)
  let comm = maintenance_clamp_score(comm_wear)
  let nav = maintenance_clamp_score(navigation_wear)

  maintenance_clamp_score(
    battery * 2 / 10 +
    motor * 2 / 10 +
    propeller * 2 / 10 +
    sensor / 10 +
    comm / 10 +
    nav * 2 / 10,
  )
}

///|
/// Check whether drone can fly from maintenance state.
pub fn maintenance_can_fly(state : Int) -> Bool {
  state == maintenance_state_healthy() || state == maintenance_state_warning()
}

///|
/// Check whether drone must be grounded.
pub fn maintenance_must_ground(state : Int, risk_score : Int) -> Bool {
  state == maintenance_state_grounded() ||
  state == maintenance_state_retired() ||
  maintenance_clamp_score(risk_score) >= 85
}

///|
/// Estimate service priority score.
pub fn maintenance_priority_score(
  risk_score : Int,
  mission_importance : Int,
  days_since_service : Int,
) -> Int {
  let risk = maintenance_clamp_score(risk_score)
  let importance = maintenance_clamp_score(mission_importance)
  let days = maintenance_clamp_count(days_since_service)
  let day_score = if days >= 120 {
    30
  } else if days >= 60 {
    20
  } else if days >= 30 {
    10
  } else {
    0
  }
  maintenance_clamp_score(risk * 5 / 10 + importance * 3 / 10 + day_score)
}

///|
/// Convert service priority to readable text.
pub fn maintenance_priority_name(priority : Int) -> String {
  let score = maintenance_clamp_score(priority)
  if score >= 85 {
    "urgent"
  } else if score >= 65 {
    "high"
  } else if score >= 35 {
    "normal"
  } else {
    "low"
  }
}

///|
/// Estimate repair minutes by fault type and severity.
pub fn maintenance_repair_minutes(fault : Int, severity : Int) -> Int {
  let safe_severity = maintenance_clamp_score(severity)
  let base = if fault == maintenance_fault_battery() {
    30
  } else if fault == maintenance_fault_motor() {
    90
  } else if fault == maintenance_fault_propeller() {
    20
  } else if fault == maintenance_fault_sensor() {
    45
  } else if fault == maintenance_fault_communication() {
    40
  } else if fault == maintenance_fault_navigation() {
    60
  } else {
    0
  }
  base + safe_severity
}

///|
/// Estimate whether repair can finish before mission.
pub fn maintenance_repair_fits_window(
  repair_minutes : Int,
  available_window_minutes : Int,
) -> Bool {
  maintenance_clamp_minutes(repair_minutes) <=
  maintenance_clamp_minutes(available_window_minutes)
}

///|
/// Estimate spare part need count.
pub fn maintenance_spare_parts_needed(
  fault : Int,
  affected_drones : Int,
) -> Int {
  let count = maintenance_clamp_count(affected_drones)
  if fault == maintenance_fault_none() {
    0
  } else if fault == maintenance_fault_propeller() {
    count * 4
  } else {
    count
  }
}

///|
/// Check whether spare parts are enough.
pub fn maintenance_spare_parts_enough(needed : Int, stock : Int) -> Bool {
  maintenance_clamp_count(stock) >= maintenance_clamp_count(needed)
}

///|
/// Estimate maintenance backlog.
pub fn maintenance_backlog_count(
  waiting_count : Int,
  service_capacity : Int,
) -> Int {
  let waiting = maintenance_clamp_count(waiting_count)
  let capacity = maintenance_clamp_count(service_capacity)
  if capacity >= waiting {
    0
  } else {
    waiting - capacity
  }
}

///|
/// Convert backlog to readable text.
pub fn maintenance_backlog_name(backlog : Int) -> String {
  let safe_backlog = maintenance_clamp_count(backlog)
  if safe_backlog >= 10 {
    "severe"
  } else if safe_backlog >= 5 {
    "high"
  } else if safe_backlog >= 2 {
    "medium"
  } else if safe_backlog == 1 {
    "low"
  } else {
    "none"
  }
}

///|
/// Estimate service capacity for technicians.
pub fn maintenance_service_capacity(
  technician_count : Int,
  minutes_per_shift : Int,
  average_repair_minutes : Int,
) -> Int {
  let tech = maintenance_clamp_count(technician_count)
  let shift = maintenance_clamp_minutes(minutes_per_shift)
  let avg = maintenance_clamp_minutes(average_repair_minutes)
  if tech <= 0 || shift <= 0 || avg <= 0 {
    0
  } else {
    tech * shift / avg
  }
}

///|
/// Check whether predictive maintenance should trigger.
pub fn maintenance_predictive_trigger(
  risk_score : Int,
  days_since_service : Int,
  upcoming_mission_importance : Int,
) -> Bool {
  let risk = maintenance_clamp_score(risk_score)
  let days = maintenance_clamp_count(days_since_service)
  let importance = maintenance_clamp_score(upcoming_mission_importance)
  risk >= 60 || days >= 90 || (risk >= 45 && importance >= 80)
}

///|
/// Maintenance module demo.
pub fn maintenance_summary() -> Unit {
  let battery = maintenance_battery_wear_score(420, 78)
  let motor = maintenance_motor_wear_score(360, 22)
  let propeller = maintenance_propeller_wear_score(80, 1)
  let sensor = maintenance_sensor_wear_score(35, 40)
  let comm = maintenance_comm_wear_score(4, 2)
  let nav = maintenance_navigation_wear_score(3, 12)

  let risk = maintenance_total_risk_score(
    battery, motor, propeller, sensor, comm, nav,
  )
  let state = maintenance_state_from_wear(risk)
  let priority = maintenance_priority_score(risk, 85, 45)
  let repair = maintenance_repair_minutes(maintenance_fault_motor(), risk)

  println("Maintenance module:")
  println("- State:")
  println(maintenance_state_name(state))
  println("- Risk level:")
  println(maintenance_wear_level_name(risk))
  println("- Service priority:")
  println(maintenance_priority_name(priority))
  println("- Fault example:")
  println(maintenance_fault_name(maintenance_fault_motor()))
  println("- Estimated repair minutes:")
  println(repair.to_string())
}
