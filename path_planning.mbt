///|
/// Path planning module for AgriDroneSwarm.

///|
pub fn path_clamp_non_negative(value: Int) -> Int {
  if value < 0 {
    0
  } else {
    value
  }
}

///|
pub fn path_clamp_percent(value: Int) -> Int {
  if value < 0 {
    0
  } else if value > 100 {
    100
  } else {
    value
  }
}

///|
pub fn path_abs_diff(a: Int, b: Int) -> Int {
  if a >= b {
    a - b
  } else {
    b - a
  }
}

///|
pub fn path_manhattan_distance_meters(
  start_x: Int,
  start_y: Int,
  end_x: Int,
  end_y: Int
) -> Int {
  path_abs_diff(start_x, end_x) + path_abs_diff(start_y, end_y)
}

///|
pub fn path_diagonal_distance_meters(
  start_x: Int,
  start_y: Int,
  end_x: Int,
  end_y: Int
) -> Int {
  let dx = path_abs_diff(start_x, end_x)
  let dy = path_abs_diff(start_y, end_y)
  let max_value = if dx >= dy { dx } else { dy }
  let min_value = if dx >= dy { dy } else { dx }
  max_value + min_value * 4 / 10
}

///|
pub fn path_turn_cost_meters(turn_count: Int, cost_per_turn_meters: Int) -> Int {
  path_clamp_non_negative(turn_count) * path_clamp_non_negative(cost_per_turn_meters)
}

///|
pub fn path_obstacle_detour_meters(
  obstacle_count: Int,
  detour_per_obstacle_meters: Int
) -> Int {
  path_clamp_non_negative(obstacle_count) * path_clamp_non_negative(detour_per_obstacle_meters)
}

///|
pub fn path_geofence_detour_meters(
  restricted_zone_count: Int,
  detour_per_zone_meters: Int
) -> Int {
  path_clamp_non_negative(restricted_zone_count) * path_clamp_non_negative(detour_per_zone_meters)
}

///|
pub fn path_total_distance_meters(
  base_distance_meters: Int,
  turn_cost_meters_value: Int,
  obstacle_detour_meters_value: Int,
  geofence_detour_meters_value: Int
) -> Int {
  path_clamp_non_negative(base_distance_meters) +
  path_clamp_non_negative(turn_cost_meters_value) +
  path_clamp_non_negative(obstacle_detour_meters_value) +
  path_clamp_non_negative(geofence_detour_meters_value)
}

///|
pub fn path_duration_minutes(distance_meters: Int, speed_meters_per_minute: Int) -> Int {
  let distance = path_clamp_non_negative(distance_meters)
  let speed = path_clamp_non_negative(speed_meters_per_minute)

  if speed <= 0 {
    0
  } else {
    (distance + speed - 1) / speed
  }
}

///|
pub fn path_battery_usage_percent(
  distance_meters: Int,
  battery_cost_per_100_meters: Int
) -> Int {
  let distance = path_clamp_non_negative(distance_meters)
  let cost = path_clamp_non_negative(battery_cost_per_100_meters)
  path_clamp_percent((distance * cost + 99) / 100)
}

///|
pub fn path_battery_feasible(
  current_battery_percent: Int,
  required_battery_percent: Int,
  reserve_battery_percent: Int
) -> Bool {
  let current = path_clamp_percent(current_battery_percent)
  let required = path_clamp_percent(required_battery_percent)
  let reserve = path_clamp_percent(reserve_battery_percent)
  current >= required + reserve
}

///|
pub fn path_complexity_score(
  waypoint_count: Int,
  turn_count: Int,
  obstacle_count: Int,
  restricted_zone_count: Int
) -> Int {
  let waypoints = path_clamp_non_negative(waypoint_count)
  let turns = path_clamp_non_negative(turn_count)
  let obstacles = path_clamp_non_negative(obstacle_count)
  let zones = path_clamp_non_negative(restricted_zone_count)
  path_clamp_percent(waypoints / 2 + turns * 3 + obstacles * 8 + zones * 12)
}

///|
pub fn path_safety_score(
  obstacle_count: Int,
  restricted_zone_count: Int,
  weather_risk_score: Int,
  sensor_quality_score: Int
) -> Int {
  let obstacles = path_clamp_non_negative(obstacle_count)
  let zones = path_clamp_non_negative(restricted_zone_count)
  let weather = path_clamp_percent(weather_risk_score)
  let sensor = path_clamp_percent(sensor_quality_score)
  let risk = obstacles * 8 + zones * 15 + weather / 2 + (100 - sensor) / 2
  path_clamp_percent(100 - risk)
}

///|
pub fn path_efficiency_score(
  direct_distance_meters: Int,
  planned_distance_meters: Int
) -> Int {
  let direct = path_clamp_non_negative(direct_distance_meters)
  let planned = path_clamp_non_negative(planned_distance_meters)

  if direct <= 0 || planned <= 0 {
    0
  } else if planned <= direct {
    100
  } else {
    path_clamp_percent(direct * 100 / planned)
  }
}

///|
pub fn path_risk_score(
  complexity_score: Int,
  safety_score: Int,
  battery_feasible_value: Bool,
  efficiency_score: Int
) -> Int {
  let complexity = path_clamp_percent(complexity_score)
  let safety = path_clamp_percent(safety_score)
  let efficiency = path_clamp_percent(efficiency_score)

  let battery_risk = if battery_feasible_value {
    0
  } else {
    30
  }

  path_clamp_percent(
    complexity / 2 + (100 - safety) / 3 + battery_risk + (100 - efficiency) / 3
  )
}

///|
pub fn path_risk_level(score: Int) -> String {
  let safe_score = path_clamp_percent(score)

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
pub fn path_strategy(
  risk_score: Int,
  obstacle_count: Int,
  restricted_zone_count: Int,
  battery_feasible_value: Bool
) -> String {
  let risk = path_clamp_percent(risk_score)
  let obstacles = path_clamp_non_negative(obstacle_count)
  let zones = path_clamp_non_negative(restricted_zone_count)

  if !battery_feasible_value {
    "return_for_battery_or_split_route"
  } else if zones > 0 {
    "geofence_aware_detour"
  } else if obstacles >= 4 {
    "obstacle_avoidance_dense"
  } else if risk >= 70 {
    "safe_conservative_path"
  } else if risk >= 35 {
    "balanced_path"
  } else {
    "direct_efficient_path"
  }
}

///|
pub fn path_need_replan(
  new_obstacle_detected: Bool,
  geofence_violation_risk: Bool,
  battery_feasible_value: Bool,
  weather_risk_score: Int
) -> Bool {
  let weather = path_clamp_percent(weather_risk_score)
  new_obstacle_detected || geofence_violation_risk || !battery_feasible_value || weather >= 70
}

///|
pub fn path_segment_count(waypoint_count: Int) -> Int {
  let waypoints = path_clamp_non_negative(waypoint_count)

  if waypoints <= 1 {
    0
  } else {
    waypoints - 1
  }
}

///|
pub fn path_average_segment_length_meters(
  total_distance_meters: Int,
  segment_count: Int
) -> Int {
  let distance = path_clamp_non_negative(total_distance_meters)
  let segments = path_clamp_non_negative(segment_count)

  if segments <= 0 {
    0
  } else {
    distance / segments
  }
}

///|
pub fn path_planning_summary() -> Unit {
  let start_x = 0
  let start_y = 0
  let end_x = 240
  let end_y = 160

  let waypoint_count = 18
  let turn_count = 9
  let obstacle_count = 3
  let restricted_zone_count = 1

  let speed = 80
  let current_battery = 76
  let battery_reserve = 20
  let battery_cost_per_100_meters = 4
  let weather_risk = 28
  let sensor_quality = 88

  let direct = path_diagonal_distance_meters(start_x, start_y, end_x, end_y)
  let manhattan = path_manhattan_distance_meters(start_x, start_y, end_x, end_y)
  let turn_cost = path_turn_cost_meters(turn_count, 6)
  let obstacle_detour = path_obstacle_detour_meters(obstacle_count, 18)
  let geofence_detour = path_geofence_detour_meters(restricted_zone_count, 35)

  let total = path_total_distance_meters(
    direct,
    turn_cost,
    obstacle_detour,
    geofence_detour
  )

  let duration = path_duration_minutes(total, speed)
  let battery_usage = path_battery_usage_percent(total, battery_cost_per_100_meters)
  let feasible = path_battery_feasible(current_battery, battery_usage, battery_reserve)
  let complexity = path_complexity_score(
    waypoint_count,
    turn_count,
    obstacle_count,
    restricted_zone_count
  )
  let safety = path_safety_score(
    obstacle_count,
    restricted_zone_count,
    weather_risk,
    sensor_quality
  )
  let efficiency = path_efficiency_score(direct, total)
  let risk = path_risk_score(complexity, safety, feasible, efficiency)
  let level = path_risk_level(risk)
  let strategy = path_strategy(
    risk,
    obstacle_count,
    restricted_zone_count,
    feasible
  )
  let replan = path_need_replan(false, false, feasible, weather_risk)
  let segments = path_segment_count(waypoint_count)
  let average_segment = path_average_segment_length_meters(total, segments)

  println("Path direct distance: " + direct.to_string() + " m")
  println("Path manhattan distance: " + manhattan.to_string() + " m")
  println("Path turn cost: " + turn_cost.to_string() + " m")
  println("Path obstacle detour: " + obstacle_detour.to_string() + " m")
  println("Path geofence detour: " + geofence_detour.to_string() + " m")
  println("Path total distance: " + total.to_string() + " m")
  println("Path duration: " + duration.to_string() + " min")
  println("Path battery usage: " + battery_usage.to_string() + "%")
  println("Path battery feasible: " + feasible.to_string())
  println("Path complexity score: " + complexity.to_string())
  println("Path safety score: " + safety.to_string())
  println("Path efficiency score: " + efficiency.to_string())
  println("Path risk score: " + risk.to_string())
  println("Path risk level: " + level)
  println("Path strategy: " + strategy)
  println("Path need replan: " + replan.to_string())
  println("Path segment count: " + segments.to_string())
  println("Path average segment: " + average_segment.to_string() + " m")
}
