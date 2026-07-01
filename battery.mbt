///|
/// Battery module for AgriDroneSwarm.
///
/// This module provides battery consumption, reserve estimation,
/// return-to-base checks, charging time, battery health, and mission safety helpers.

///|
/// Battery mode: idle.
pub fn battery_mode_idle() -> Int {
  0
}

///|
/// Battery mode: cruise.
pub fn battery_mode_cruise() -> Int {
  1
}

///|
/// Battery mode: survey.
pub fn battery_mode_survey() -> Int {
  2
}

///|
/// Battery mode: spray.
pub fn battery_mode_spray() -> Int {
  3
}

///|
/// Battery mode: return-to-base.
pub fn battery_mode_return() -> Int {
  4
}

///|
/// Convert battery mode to readable text.
pub fn battery_mode_name(mode: Int) -> String {
  match mode {
    0 => "idle"
    1 => "cruise"
    2 => "survey"
    3 => "spray"
    4 => "return-to-base"
    _ => "unknown"
  }
}

///|
/// Battery state: full.
pub fn battery_state_full() -> Int {
  0
}

///|
/// Battery state: normal.
pub fn battery_state_normal() -> Int {
  1
}

///|
/// Battery state: low.
pub fn battery_state_low() -> Int {
  2
}

///|
/// Battery state: critical.
pub fn battery_state_critical() -> Int {
  3
}

///|
/// Battery state: empty.
pub fn battery_state_empty() -> Int {
  4
}

///|
/// Convert battery state to readable text.
pub fn battery_state_name(state: Int) -> String {
  match state {
    0 => "full"
    1 => "normal"
    2 => "low"
    3 => "critical"
    4 => "empty"
    _ => "unknown"
  }
}

///|
/// Clamp percent into 0..100.
pub fn battery_clamp_percent(value: Int) -> Int {
  if value < 0 {
    0
  } else if value > 100 {
    100
  } else {
    value
  }
}

///|
/// Clamp non-negative integer.
pub fn battery_clamp_non_negative(value: Int) -> Int {
  if value < 0 {
    0
  } else {
    value
  }
}

///|
/// Clamp positive integer.
pub fn battery_clamp_positive(value: Int) -> Int {
  if value <= 0 {
    1
  } else {
    value
  }
}

///|
/// Convert battery percent to state.
pub fn battery_state_from_percent(percent: Int) -> Int {
  let p = battery_clamp_percent(percent)
  if p >= 90 {
    battery_state_full()
  } else if p >= 35 {
    battery_state_normal()
  } else if p >= 20 {
    battery_state_low()
  } else if p > 0 {
    battery_state_critical()
  } else {
    battery_state_empty()
  }
}

///|
/// Convert battery percent to readable level.
pub fn battery_percent_level_name(percent: Int) -> String {
  battery_state_name(battery_state_from_percent(percent))
}

///|
/// Estimate base drain percent per minute by mode.
pub fn battery_mode_drain_per_minute(mode: Int) -> Int {
  if mode == battery_mode_idle() {
    1
  } else if mode == battery_mode_cruise() {
    2
  } else if mode == battery_mode_survey() {
    3
  } else if mode == battery_mode_spray() {
    4
  } else if mode == battery_mode_return() {
    2
  } else {
    2
  }
}

///|
/// Estimate payload drain penalty.
pub fn battery_payload_drain_penalty(payload_kg: Int) -> Int {
  let payload = battery_clamp_non_negative(payload_kg)
  if payload >= 30 {
    3
  } else if payload >= 20 {
    2
  } else if payload >= 10 {
    1
  } else {
    0
  }
}

///|
/// Estimate wind drain penalty.
pub fn battery_wind_drain_penalty(wind_speed: Int) -> Int {
  let wind = battery_clamp_non_negative(wind_speed)
  if wind >= 18 {
    4
  } else if wind >= 12 {
    3
  } else if wind >= 7 {
    1
  } else {
    0
  }
}

///|
/// Estimate temperature drain penalty.
pub fn battery_temperature_drain_penalty(temperature_c: Int) -> Int {
  if temperature_c <= -5 {
    3
  } else if temperature_c <= 5 {
    2
  } else if temperature_c >= 38 {
    3
  } else if temperature_c >= 32 {
    1
  } else {
    0
  }
}

///|
/// Estimate total drain percent per minute.
pub fn battery_drain_per_minute(
  mode: Int,
  payload_kg: Int,
  wind_speed: Int,
  temperature_c: Int
) -> Int {
  battery_mode_drain_per_minute(mode) +
  battery_payload_drain_penalty(payload_kg) +
  battery_wind_drain_penalty(wind_speed) +
  battery_temperature_drain_penalty(temperature_c)
}

///|
/// Estimate battery consumption percent for a mission segment.
pub fn battery_consumption_percent(
  minutes: Int,
  mode: Int,
  payload_kg: Int,
  wind_speed: Int,
  temperature_c: Int
) -> Int {
  let safe_minutes = battery_clamp_non_negative(minutes)
  let drain = battery_drain_per_minute(mode, payload_kg, wind_speed, temperature_c)
  battery_clamp_percent(safe_minutes * drain)
}

///|
/// Estimate remaining battery after a segment.
pub fn battery_remaining_after_segment(
  current_percent: Int,
  minutes: Int,
  mode: Int,
  payload_kg: Int,
  wind_speed: Int,
  temperature_c: Int
) -> Int {
  let current = battery_clamp_percent(current_percent)
  let used = battery_consumption_percent(minutes, mode, payload_kg, wind_speed, temperature_c)
  battery_clamp_percent(current - used)
}

///|
/// Estimate return-to-base battery requirement.
pub fn battery_return_required_percent(distance_meters: Int, wind_speed: Int) -> Int {
  let distance = battery_clamp_non_negative(distance_meters)
  let wind = battery_clamp_non_negative(wind_speed)
  let distance_cost = (distance + 499) / 500
  let wind_cost = if wind >= 15 {
    8
  } else if wind >= 10 {
    5
  } else if wind >= 6 {
    2
  } else {
    0
  }
  battery_clamp_percent(10 + distance_cost + wind_cost)
}

///|
/// Estimate reserve battery requirement.
pub fn battery_reserve_required_percent(mission_risk: Int) -> Int {
  let risk = battery_clamp_percent(mission_risk)
  if risk >= 80 {
    30
  } else if risk >= 60 {
    25
  } else if risk >= 35 {
    20
  } else {
    15
  }
}

///|
/// Estimate total safe battery requirement.
pub fn battery_safe_required_percent(
  mission_consumption: Int,
  return_required: Int,
  reserve_required: Int
) -> Int {
  battery_clamp_percent(
    battery_clamp_percent(mission_consumption) +
    battery_clamp_percent(return_required) +
    battery_clamp_percent(reserve_required),
  )
}

///|
/// Check whether current battery can start mission.
pub fn battery_can_start_mission(
  current_percent: Int,
  mission_consumption: Int,
  return_required: Int,
  reserve_required: Int
) -> Bool {
  let current = battery_clamp_percent(current_percent)
  let required = battery_safe_required_percent(
    mission_consumption,
    return_required,
    reserve_required,
  )
  current >= required
}

///|
/// Check whether drone should return to base.
pub fn battery_should_return_to_base(
  current_percent: Int,
  distance_meters: Int,
  wind_speed: Int,
  mission_risk: Int
) -> Bool {
  let current = battery_clamp_percent(current_percent)
  let return_required = battery_return_required_percent(distance_meters, wind_speed)
  let reserve = battery_reserve_required_percent(mission_risk)
  current <= return_required + reserve
}

///|
/// Estimate emergency landing need.
pub fn battery_emergency_landing_required(current_percent: Int) -> Bool {
  battery_clamp_percent(current_percent) <= 8
}

///|
/// Estimate available flight minutes.
pub fn battery_available_minutes(
  current_percent: Int,
  mode: Int,
  payload_kg: Int,
  wind_speed: Int,
  temperature_c: Int
) -> Int {
  let current = battery_clamp_percent(current_percent)
  let drain = battery_clamp_positive(
    battery_drain_per_minute(mode, payload_kg, wind_speed, temperature_c),
  )
  current / drain
}

///|
/// Estimate charge speed percent per minute.
pub fn battery_charge_rate_per_minute(charger_watt: Int) -> Int {
  let watt = battery_clamp_non_negative(charger_watt)
  if watt >= 1000 {
    4
  } else if watt >= 600 {
    3
  } else if watt >= 300 {
    2
  } else {
    1
  }
}

///|
/// Estimate charging minutes required.
pub fn battery_charge_minutes(
  current_percent: Int,
  target_percent: Int,
  charger_watt: Int
) -> Int {
  let current = battery_clamp_percent(current_percent)
  let target = battery_clamp_percent(target_percent)
  let rate = battery_charge_rate_per_minute(charger_watt)
  if target <= current {
    0
  } else {
    let need = target - current
    (need + rate - 1) / rate
  }
}

///|
/// Estimate battery health score from cycle count and age.
pub fn battery_health_score(cycle_count: Int, age_days: Int, deep_discharge_count: Int) -> Int {
  let cycles = battery_clamp_non_negative(cycle_count)
  let age = battery_clamp_non_negative(age_days)
  let deep = battery_clamp_non_negative(deep_discharge_count)

  let cycle_penalty = if cycles >= 900 {
    45
  } else if cycles >= 600 {
    30
  } else if cycles >= 300 {
    15
  } else {
    5
  }

  let age_penalty = if age >= 900 {
    30
  } else if age >= 600 {
    20
  } else if age >= 300 {
    10
  } else {
    2
  }

  battery_clamp_percent(100 - cycle_penalty - age_penalty - deep * 5)
}

///|
/// Convert battery health score to readable text.
pub fn battery_health_name(health: Int) -> String {
  let h = battery_clamp_percent(health)
  if h >= 85 {
    "excellent"
  } else if h >= 70 {
    "good"
  } else if h >= 50 {
    "aging"
  } else if h >= 30 {
    "poor"
  } else {
    "replace"
  }
}

///|
/// Check whether battery is healthy enough for normal use.
pub fn battery_healthy_for_use(health: Int) -> Bool {
  battery_clamp_percent(health) >= 50
}

///|
/// Check whether battery should be replaced.
pub fn battery_replace_recommended(health: Int, cycle_count: Int) -> Bool {
  battery_clamp_percent(health) < 30 || battery_clamp_non_negative(cycle_count) >= 1000
}

///|
/// Estimate battery risk score.
pub fn battery_risk_score(
  current_percent: Int,
  health_score: Int,
  mission_consumption: Int,
  return_required: Int,
  reserve_required: Int
) -> Int {
  let current = battery_clamp_percent(current_percent)
  let health = battery_clamp_percent(health_score)
  let required = battery_safe_required_percent(
    mission_consumption,
    return_required,
    reserve_required,
  )
  let shortage = if required > current {
    required - current
  } else {
    0
  }
  battery_clamp_percent(shortage * 2 + (100 - health) / 2)
}

///|
/// Convert battery risk score to readable text.
pub fn battery_risk_name(risk: Int) -> String {
  let r = battery_clamp_percent(risk)
  if r >= 80 {
    "critical"
  } else if r >= 60 {
    "high"
  } else if r >= 35 {
    "medium"
  } else {
    "low"
  }
}

///|
/// Estimate mission battery status text.
pub fn battery_mission_status(
  current_percent: Int,
  mission_consumption: Int,
  return_required: Int,
  reserve_required: Int
) -> String {
  if battery_can_start_mission(
    current_percent,
    mission_consumption,
    return_required,
    reserve_required,
  ) {
    "battery-ready"
  } else {
    "battery-insufficient"
  }
}

///|
/// Battery module demo.
pub fn battery_summary() -> Unit {
  let current = 86
  let mode = battery_mode_survey()
  let payload = 8
  let wind = 7
  let temperature = 28
  let mission_minutes = 18
  let distance = 1800
  let mission_risk = 40

  let drain = battery_drain_per_minute(mode, payload, wind, temperature)
  let consumption = battery_consumption_percent(
    mission_minutes,
    mode,
    payload,
    wind,
    temperature,
  )
  let remaining = battery_remaining_after_segment(
    current,
    mission_minutes,
    mode,
    payload,
    wind,
    temperature,
  )
  let return_required = battery_return_required_percent(distance, wind)
  let reserve = battery_reserve_required_percent(mission_risk)
  let required = battery_safe_required_percent(consumption, return_required, reserve)
  let can_start = battery_can_start_mission(current, consumption, return_required, reserve)
  let health = battery_health_score(420, 380, 2)
  let risk = battery_risk_score(current, health, consumption, return_required, reserve)

  println("Battery module:")
  println("- Mode:")
  println(battery_mode_name(mode))
  println("- Current battery level:")
  println(battery_percent_level_name(current))
  println("- Drain percent per minute:")
  println(drain)
  println("- Mission consumption percent:")
  println(consumption)
  println("- Remaining after segment:")
  println(remaining)
  println("- Required safe battery:")
  println(required)
  println("- Can start mission:")
  println(can_start)
  println("- Should return to base:")
  println(battery_should_return_to_base(remaining, distance, wind, mission_risk))
  println("- Battery health:")
  println(battery_health_name(health))
  println("- Battery risk:")
  println(battery_risk_name(risk))
}
