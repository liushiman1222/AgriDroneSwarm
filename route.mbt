///|
/// Route module for AgriDroneSwarm.
/// Handles route distance, duration, risk, efficiency, and action suggestion.

///|
/// Clamp non-negative integer.
pub fn route_clamp_non_negative(value: Int) -> Int {
  if value < 0 {
    0
  } else {
    value
  }
}

///|
/// Clamp percent to 0..100.
pub fn route_clamp_percent(value: Int) -> Int {
  if value < 0 {
    0
  } else if value > 100 {
    100
  } else {
    value
  }
}

///|
/// Absolute difference.
pub fn route_abs_diff(a: Int, b: Int) -> Int {
  if a >= b {
    a - b
  } else {
    b - a
  }
}

///|
/// Manhattan distance between two points.
pub fn route_distance_meters(x1: Int, y1: Int, x2: Int, y2: Int) -> Int {
  route_abs_diff(x1, x2) + route_abs_diff(y1, y2)
}

///|
/// Estimate total route distance for a simple rectangular pattern.
pub fn route_rectangular_distance_meters(
  width_meters: Int,
  height_meters: Int,
  lane_spacing_meters: Int
) -> Int {
  let width = route_clamp_non_negative(width_meters)
  let height = route_clamp_non_negative(height_meters)
  let spacing = route_clamp_non_negative(lane_spacing_meters)

  if spacing <= 0 {
    0
  } else {
    let lanes = height / spacing + 1
    lanes * width + height
  }
}

///|
/// Estimate waypoint count.
pub fn route_waypoint_count(
  width_meters: Int,
  height_meters: Int,
  lane_spacing_meters: Int
) -> Int {
  let width = route_clamp_non_negative(width_meters)
  let height = route_clamp_non_negative(height_meters)
  let spacing = route_clamp_non_negative(lane_spacing_meters)

  if width <= 0 || height <= 0 || spacing <= 0 {
    0
  } else {
    let lanes = height / spacing + 1
    lanes * 2
  }
}

///|
/// Estimate route duration in minutes.
pub fn route_duration_minutes(distance_meters: Int, speed_mps: Int) -> Int {
  let distance = route_clamp_non_negative(distance_meters)
  let speed = route_clamp_non_negative(speed_mps)

  if speed <= 0 {
    0
  } else {
    let seconds = (distance + speed - 1) / speed
    (seconds + 59) / 60
  }
}

///|
/// Estimate turn penalty minutes.
pub fn route_turn_penalty_minutes(waypoint_count: Int) -> Int {
  let count = route_clamp_non_negative(waypoint_count)
  count / 6
}

///|
/// Estimate total route time.
pub fn route_total_time_minutes(
  distance_meters: Int,
  speed_mps: Int,
  waypoint_count: Int
) -> Int {
  route_duration_minutes(distance_meters, speed_mps) +
  route_turn_penalty_minutes(waypoint_count)
}

///|
/// Estimate route battery usage percent.
pub fn route_battery_usage_percent(
  total_time_minutes: Int,
  battery_drain_per_minute: Int
) -> Int {
  let time = route_clamp_non_negative(total_time_minutes)
  let drain = route_clamp_non_negative(battery_drain_per_minute)
  route_clamp_percent(time * drain)
}

///|
/// Estimate route coverage efficiency.
pub fn route_efficiency_score(
  field_area_square_meter: Int,
  distance_meters: Int
) -> Int {
  let area = route_clamp_non_negative(field_area_square_meter)
  let distance = route_clamp_non_negative(distance_meters)

  if area <= 0 || distance <= 0 {
    0
  } else {
    route_clamp_percent(area / distance)
  }
}

///|
/// Estimate route risk score.
pub fn route_risk_score(
  obstacle_risk: Int,
  geofence_risk: Int,
  weather_risk: Int,
  battery_usage: Int
) -> Int {
  let obstacle = route_clamp_percent(obstacle_risk)
  let geofence = route_clamp_percent(geofence_risk)
  let weather = route_clamp_percent(weather_risk)
  let battery = route_clamp_percent(battery_usage)

  route_clamp_percent((obstacle + geofence + weather + battery) / 4)
}

///|
/// Convert route risk score to level.
pub fn route_risk_level(score: Int) -> String {
  let safe_score = route_clamp_percent(score)

  if safe_score >= 80 {
    "critical"
  } else if safe_score >= 60 {
    "high"
  } else if safe_score >= 35 {
    "medium"
  } else {
    "low"
  }
}

///|
/// Check whether route can start.
pub fn route_can_start(
  risk_score: Int,
  battery_percent: Int,
  required_battery_percent: Int
) -> Bool {
  let risk = route_clamp_percent(risk_score)
  let battery = route_clamp_percent(battery_percent)
  let required = route_clamp_percent(required_battery_percent)

  risk < 70 && battery >= required
}

///|
/// Recommend route action.
pub fn route_action(
  risk_score: Int,
  can_start: Bool
) -> String {
  let risk = route_clamp_percent(risk_score)

  if !can_start {
    "hold"
  } else if risk >= 60 {
    "replan_before_start"
  } else if risk >= 35 {
    "start_with_monitoring"
  } else {
    "start"
  }
}

///|
/// Estimate reserve battery after route.
pub fn route_reserve_battery_percent(
  battery_percent: Int,
  usage_percent: Int
) -> Int {
  let battery = route_clamp_percent(battery_percent)
  let usage = route_clamp_percent(usage_percent)

  if usage >= battery {
    0
  } else {
    battery - usage
  }
}

///|
/// Check whether route needs split.
pub fn route_need_split(
  total_time_minutes: Int,
  max_single_flight_minutes: Int
) -> Bool {
  route_clamp_non_negative(total_time_minutes) >
  route_clamp_non_negative(max_single_flight_minutes)
}

///|
/// Estimate split count.
pub fn route_split_count(
  total_time_minutes: Int,
  max_single_flight_minutes: Int
) -> Int {
  let total = route_clamp_non_negative(total_time_minutes)
  let max_time = route_clamp_non_negative(max_single_flight_minutes)

  if max_time <= 0 {
    0
  } else {
    (total + max_time - 1) / max_time
  }
}

///|
/// Print route module summary.
pub fn route_summary() -> Unit {
  let field_width = 300
  let field_height = 180
  let lane_spacing = 12
  let speed = 6
  let battery_drain = 2
  let battery = 86
  let max_single_flight = 25
  let obstacle_risk = 42
  let geofence_risk = 28
  let weather_risk = 35

  let distance = route_rectangular_distance_meters(field_width, field_height, lane_spacing)
  let waypoint_count = route_waypoint_count(field_width, field_height, lane_spacing)
  let duration = route_duration_minutes(distance, speed)
  let turn_penalty = route_turn_penalty_minutes(waypoint_count)
  let total_time = route_total_time_minutes(distance, speed, waypoint_count)
  let usage = route_battery_usage_percent(total_time, battery_drain)
  let reserve = route_reserve_battery_percent(battery, usage)
  let efficiency = route_efficiency_score(field_width * field_height, distance)
  let risk = route_risk_score(obstacle_risk, geofence_risk, weather_risk, usage)
  let level = route_risk_level(risk)
  let can_start = route_can_start(risk, battery, usage + 15)
  let action = route_action(risk, can_start)
  let need_split = route_need_split(total_time, max_single_flight)
  let split_count = route_split_count(total_time, max_single_flight)

  println("Route field size: " + field_width.to_string() + " x " + field_height.to_string() + " m")
  println("Route lane spacing: " + lane_spacing.to_string() + " m")
  println("Route distance: " + distance.to_string() + " m")
  println("Route waypoint count: " + waypoint_count.to_string())
  println("Route duration: " + duration.to_string() + " min")
  println("Route turn penalty: " + turn_penalty.to_string() + " min")
  println("Route total time: " + total_time.to_string() + " min")
  println("Route battery usage: " + usage.to_string() + "%")
  println("Route reserve battery: " + reserve.to_string() + "%")
  println("Route efficiency score: " + efficiency.to_string())
  println("Route risk score: " + risk.to_string())
  println("Route risk level: " + level)
  println("Route can start: " + can_start.to_string())
  println("Route action: " + action)
  println("Route need split: " + need_split.to_string())
  println("Route split count: " + split_count.to_string())
}
