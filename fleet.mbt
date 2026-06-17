///|
/// Fleet module for AgriDroneSwarm.
///
/// This module provides simple fleet availability,
/// drone readiness, workload balance, and dispatch helpers.

///|
/// Drone status: idle.
pub fn fleet_status_idle() -> Int {
  0
}

///|
/// Drone status: assigned.
pub fn fleet_status_assigned() -> Int {
  1
}

///|
/// Drone status: charging.
pub fn fleet_status_charging() -> Int {
  2
}

///|
/// Drone status: maintenance.
pub fn fleet_status_maintenance() -> Int {
  3
}

///|
/// Drone status: offline.
pub fn fleet_status_offline() -> Int {
  4
}

///|
/// Convert fleet status to readable text.
pub fn fleet_status_name(status: Int) -> String {
  match status {
    0 => "idle"
    1 => "assigned"
    2 => "charging"
    3 => "maintenance"
    4 => "offline"
    _ => "unknown"
  }
}

///|
/// Clamp drone count into non-negative range.
pub fn clamp_drone_count(count: Int) -> Int {
  if count < 0 {
    0
  } else {
    count
  }
}

///|
/// Clamp battery into 0..100.
pub fn fleet_fleet_fleet_fleet_fleet_fleet_fleet_fleet_clamp_battery(value: Int) -> Int {
  if value < 0 {
    0
  } else if value > 100 {
    100
  } else {
    value
  }
}
///|
/// Check whether one drone status is available for dispatch.
pub fn fleet_status_available(status: Int) -> Bool {
  status == fleet_status_idle()
}

///|
/// Check whether one drone needs operator attention.
pub fn fleet_status_needs_attention(status: Int) -> Bool {
  status == fleet_status_maintenance() || status == fleet_status_offline()
}

///|
/// Check whether drone battery is enough for dispatch.
pub fn fleet_battery_ready(battery: Int, required_battery: Int) -> Bool {
  fleet_fleet_fleet_fleet_fleet_fleet_fleet_fleet_clamp_battery(battery) >= fleet_fleet_fleet_fleet_fleet_fleet_fleet_fleet_clamp_battery(required_battery)
}

///|
/// Check whether payload capacity is enough.
pub fn fleet_payload_ready(capacity: Int, required_payload: Int) -> Bool {
  let safe_capacity = if capacity < 0 { 0 } else { capacity }
  let safe_required = if required_payload < 0 { 0 } else { required_payload }
  safe_capacity >= safe_required
}

///|
/// Full readiness check for a single drone.
pub fn fleet_drone_ready(
  status: Int,
  battery: Int,
  required_battery: Int,
  capacity: Int,
  required_payload: Int
) -> Bool {
  fleet_status_available(status) &&
  fleet_battery_ready(battery, required_battery) &&
  fleet_payload_ready(capacity, required_payload)
}

///|
/// Count available drones.
pub fn fleet_available_count(
  idle_count: Int,
  assigned_count: Int,
  charging_count: Int,
  maintenance_count: Int,
  offline_count: Int
) -> Int {
  let _ = assigned_count
  let _ = charging_count
  let _ = maintenance_count
  let _ = offline_count
  clamp_drone_count(idle_count)
}

///|
/// Count unavailable drones.
pub fn fleet_unavailable_count(
  idle_count: Int,
  assigned_count: Int,
  charging_count: Int,
  maintenance_count: Int,
  offline_count: Int
) -> Int {
  let _ = idle_count
  clamp_drone_count(assigned_count) +
  clamp_drone_count(charging_count) +
  clamp_drone_count(maintenance_count) +
  clamp_drone_count(offline_count)
}

///|
/// Count total fleet size.
pub fn fleet_total_count(
  idle_count: Int,
  assigned_count: Int,
  charging_count: Int,
  maintenance_count: Int,
  offline_count: Int
) -> Int {
  clamp_drone_count(idle_count) +
  clamp_drone_count(assigned_count) +
  clamp_drone_count(charging_count) +
  clamp_drone_count(maintenance_count) +
  clamp_drone_count(offline_count)
}

///|
/// Estimate fleet availability percent.
pub fn fleet_availability_percent(
  idle_count: Int,
  assigned_count: Int,
  charging_count: Int,
  maintenance_count: Int,
  offline_count: Int
) -> Int {
  let total = fleet_total_count(
    idle_count,
    assigned_count,
    charging_count,
    maintenance_count,
    offline_count,
  )
  if total <= 0 {
    0
  } else {
    clamp_percent(clamp_drone_count(idle_count) * 100 / total)
  }
}

///|
/// Convert fleet availability to readable level.
pub fn fleet_availability_name(percent: Int) -> String {
  let safe_percent = clamp_percent(percent)
  if safe_percent >= 80 {
    "high"
  } else if safe_percent >= 50 {
    "normal"
  } else if safe_percent >= 25 {
    "limited"
  } else {
    "critical"
  }
}

///|
/// Estimate fleet workload percent.
pub fn fleet_workload_percent(assigned_count: Int, total_count: Int) -> Int {
  let assigned = clamp_drone_count(assigned_count)
  let total = clamp_drone_count(total_count)
  if total <= 0 {
    0
  } else {
    clamp_percent(assigned * 100 / total)
  }
}

///|
/// Convert workload percent to readable level.
pub fn fleet_workload_name(percent: Int) -> String {
  let safe_percent = clamp_percent(percent)
  if safe_percent >= 90 {
    "overloaded"
  } else if safe_percent >= 70 {
    "busy"
  } else if safe_percent >= 35 {
    "normal"
  } else {
    "light"
  }
}

///|
/// Estimate minimum drones needed by mission area.
pub fn fleet_required_drones_by_area(field_area: Int, drone_capacity_area: Int) -> Int {
  let safe_area = if field_area < 0 { 0 } else { field_area }
  let safe_capacity = if drone_capacity_area <= 0 { 1 } else { drone_capacity_area }
  if safe_area <= 0 {
    0
  } else {
    (safe_area + safe_capacity - 1) / safe_capacity
  }
}

///|
/// Estimate minimum drones needed by mission duration.
pub fn fleet_required_drones_by_time(total_minutes: Int, max_minutes_per_drone: Int) -> Int {
  let safe_total = if total_minutes < 0 { 0 } else { total_minutes }
  let safe_max = if max_minutes_per_drone <= 0 { 1 } else { max_minutes_per_drone }
  if safe_total <= 0 {
    0
  } else {
    (safe_total + safe_max - 1) / safe_max
  }
}

///|
/// Choose larger requirement from area and time.
pub fn fleet_required_drones(
  field_area: Int,
  drone_capacity_area: Int,
  total_minutes: Int,
  max_minutes_per_drone: Int
) -> Int {
  let by_area = fleet_required_drones_by_area(field_area, drone_capacity_area)
  let by_time = fleet_required_drones_by_time(total_minutes, max_minutes_per_drone)
  if by_area > by_time {
    by_area
  } else {
    by_time
  }
}

///|
/// Check whether fleet can dispatch enough drones.
pub fn fleet_can_dispatch(available_count: Int, required_count: Int) -> Bool {
  clamp_drone_count(available_count) >= clamp_drone_count(required_count)
}

///|
/// Estimate dispatch shortage.
pub fn fleet_dispatch_shortage(available_count: Int, required_count: Int) -> Int {
  let available = clamp_drone_count(available_count)
  let required = clamp_drone_count(required_count)
  if available >= required {
    0
  } else {
    required - available
  }
}

///|
/// Estimate backup drones recommended.
pub fn fleet_backup_recommended(required_count: Int) -> Int {
  let required = clamp_drone_count(required_count)
  if required <= 2 {
    1
  } else {
    (required + 3) / 4
  }
}

///|
/// Check whether fleet has enough backup drones.
pub fn fleet_backup_enough(available_count: Int, required_count: Int) -> Bool {
  let available = clamp_drone_count(available_count)
  let required = clamp_drone_count(required_count)
  let backup = fleet_backup_recommended(required)
  available >= required + backup
}

///|
/// Estimate charging demand.
pub fn fleet_charging_demand(low_battery_count: Int, charging_count: Int) -> Int {
  let low = clamp_drone_count(low_battery_count)
  let charging = clamp_drone_count(charging_count)
  if charging >= low {
    0
  } else {
    low - charging
  }
}

///|
/// Convert charging demand to readable level.
pub fn fleet_charging_demand_name(demand: Int) -> String {
  let safe_demand = clamp_drone_count(demand)
  if safe_demand >= 5 {
    "high"
  } else if safe_demand >= 2 {
    "medium"
  } else if safe_demand == 1 {
    "low"
  } else {
    "none"
  }
}

///|
/// Estimate maintenance pressure percent.
pub fn fleet_maintenance_pressure_percent(maintenance_count: Int, total_count: Int) -> Int {
  let maintenance = clamp_drone_count(maintenance_count)
  let total = clamp_drone_count(total_count)
  if total <= 0 {
    0
  } else {
    clamp_percent(maintenance * 100 / total)
  }
}

///|
/// Convert maintenance pressure to readable level.
pub fn fleet_maintenance_pressure_name(percent: Int) -> String {
  let safe_percent = clamp_percent(percent)
  if safe_percent >= 30 {
    "critical"
  } else if safe_percent >= 15 {
    "high"
  } else if safe_percent >= 5 {
    "normal"
  } else {
    "low"
  }
}

///|
/// Estimate fleet health score.
pub fn fleet_health_score(
  idle_count: Int,
  assigned_count: Int,
  charging_count: Int,
  maintenance_count: Int,
  offline_count: Int
) -> Int {
  let total = fleet_total_count(
    idle_count,
    assigned_count,
    charging_count,
    maintenance_count,
    offline_count,
  )
  if total <= 0 {
    0
  } else {
    let idle_score = clamp_drone_count(idle_count) * 100 / total
    let assigned_score = clamp_drone_count(assigned_count) * 70 / total
    let charging_score = clamp_drone_count(charging_count) * 55 / total
    let maintenance_penalty = clamp_drone_count(maintenance_count) * 30 / total
    let offline_penalty = clamp_drone_count(offline_count) * 45 / total
    clamp_percent(idle_score + assigned_score + charging_score - maintenance_penalty - offline_penalty)
  }
}

///|
/// Convert fleet health score to readable level.
pub fn fleet_health_name(score: Int) -> String {
  let safe_score = clamp_percent(score)
  if safe_score >= 85 {
    "excellent"
  } else if safe_score >= 70 {
    "good"
  } else if safe_score >= 50 {
    "warning"
  } else {
    "poor"
  }
}

///|
/// Check whether fleet requires maintenance planning.
pub fn fleet_requires_maintenance_plan(
  maintenance_count: Int,
  offline_count: Int,
  total_count: Int
) -> Bool {
  let total = clamp_drone_count(total_count)
  if total <= 0 {
    false
  } else {
    let bad = clamp_drone_count(maintenance_count) + clamp_drone_count(offline_count)
    bad * 100 / total >= 20
  }
}

///|
/// Estimate mission dispatch risk.
pub fn fleet_dispatch_risk_score(
  available_count: Int,
  required_count: Int,
  backup_required: Int,
  weather_risk: Int
) -> Int {
  let available = clamp_drone_count(available_count)
  let required = clamp_drone_count(required_count)
  let backup = clamp_drone_count(backup_required)
  let shortage = fleet_dispatch_shortage(available, required)
  let backup_gap = if available >= required + backup {
    0
  } else {
    required + backup - available
  }
  clamp_percent(shortage * 30 + backup_gap * 15 + weather_risk / 2)
}

///|
/// Convert dispatch risk score to readable level.
pub fn fleet_dispatch_risk_name(score: Int) -> String {
  let safe_score = clamp_percent(score)
  if safe_score >= 80 {
    "critical"
  } else if safe_score >= 55 {
    "high"
  } else if safe_score >= 25 {
    "medium"
  } else {
    "low"
  }
}

///|
/// Check whether dispatch should be delayed.
pub fn fleet_should_delay_dispatch(
  available_count: Int,
  required_count: Int,
  weather_risk: Int
) -> Bool {
  let backup = fleet_backup_recommended(required_count)
  let risk = fleet_dispatch_risk_score(
    available_count,
    required_count,
    backup,
    weather_risk,
  )
  risk >= 55
}

///|
/// Fleet module demo.
pub fn fleet_summary() -> Unit {
  let idle = 7
  let assigned = 3
  let charging = 2
  let maintenance = 1
  let offline = 0

  let total = fleet_total_count(idle, assigned, charging, maintenance, offline)
  let available = fleet_available_count(idle, assigned, charging, maintenance, offline)
  let availability = fleet_availability_percent(idle, assigned, charging, maintenance, offline)
  let workload = fleet_workload_percent(assigned, total)
  let health = fleet_health_score(idle, assigned, charging, maintenance, offline)
  let required = fleet_required_drones(12000, 3000, 180, 60)
  let backup = fleet_backup_recommended(required)
  let risk = fleet_dispatch_risk_score(available, required, backup, 20)

  println("Fleet module:")
  println("- Fleet status: idle, assigned, charging, maintenance, offline")
  println("- Dispatch rule: available drones must cover required drones and backup")
  println("- Health rule: idle and assigned are positive, maintenance and offline reduce score")
  println("- Total drones:")
  println(total)
  println("- Availability:")
  println(fleet_availability_name(availability))
  println("- Workload:")
  println(fleet_workload_name(workload))
  println("- Fleet health:")
  println(fleet_health_name(health))
  println("- Dispatch risk:")
  println(fleet_dispatch_risk_name(risk))
}
