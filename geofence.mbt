///|
/// Geofence module for AgriDroneSwarm.
/// Handles field boundary, no-fly margin, out-of-bound risk,
/// and return-to-field decisions.

///|
/// Clamp non-negative integer.
pub fn geofence_clamp_non_negative(value: Int) -> Int {
  if value < 0 {
    0
  } else {
    value
  }
}

///|
/// Clamp percent to 0..100.
pub fn geofence_clamp_percent(value: Int) -> Int {
  if value < 0 {
    0
  } else if value > 100 {
    100
  } else {
    value
  }
}

///|
/// Check whether x is inside range.
pub fn geofence_in_range(value: Int, min_value: Int, max_value: Int) -> Bool {
  value >= min_value && value <= max_value
}

///|
/// Check whether a point is inside rectangular field.
pub fn geofence_point_inside(
  x: Int,
  y: Int,
  min_x: Int,
  min_y: Int,
  max_x: Int,
  max_y: Int
) -> Bool {
  geofence_in_range(x, min_x, max_x) && geofence_in_range(y, min_y, max_y)
}

///|
/// Distance to left boundary.
pub fn geofence_distance_left(x: Int, min_x: Int) -> Int {
  if x < min_x {
    0
  } else {
    x - min_x
  }
}

///|
/// Distance to right boundary.
pub fn geofence_distance_right(x: Int, max_x: Int) -> Int {
  if x > max_x {
    0
  } else {
    max_x - x
  }
}

///|
/// Distance to bottom boundary.
pub fn geofence_distance_bottom(y: Int, min_y: Int) -> Int {
  if y < min_y {
    0
  } else {
    y - min_y
  }
}

///|
/// Distance to top boundary.
pub fn geofence_distance_top(y: Int, max_y: Int) -> Int {
  if y > max_y {
    0
  } else {
    max_y - y
  }
}

///|
/// Minimum distance to any boundary.
pub fn geofence_min_boundary_distance(
  x: Int,
  y: Int,
  min_x: Int,
  min_y: Int,
  max_x: Int,
  max_y: Int
) -> Int {
  let left = geofence_distance_left(x, min_x)
  let right = geofence_distance_right(x, max_x)
  let bottom = geofence_distance_bottom(y, min_y)
  let top = geofence_distance_top(y, max_y)

  let horizontal = if left < right { left } else { right }
  let vertical = if bottom < top { bottom } else { top }

  if horizontal < vertical {
    horizontal
  } else {
    vertical
  }
}

///|
/// Check whether drone is close to boundary.
pub fn geofence_near_boundary(
  x: Int,
  y: Int,
  min_x: Int,
  min_y: Int,
  max_x: Int,
  max_y: Int,
  margin: Int
) -> Bool {
  let safe_margin = geofence_clamp_non_negative(margin)
  let inside = geofence_point_inside(x, y, min_x, min_y, max_x, max_y)

  if !inside {
    true
  } else {
    geofence_min_boundary_distance(x, y, min_x, min_y, max_x, max_y) <= safe_margin
  }
}

///|
/// Estimate outside distance.
/// If point is inside field, result is 0.
pub fn geofence_outside_distance(
  x: Int,
  y: Int,
  min_x: Int,
  min_y: Int,
  max_x: Int,
  max_y: Int
) -> Int {
  let dx = if x < min_x {
    min_x - x
  } else if x > max_x {
    x - max_x
  } else {
    0
  }

  let dy = if y < min_y {
    min_y - y
  } else if y > max_y {
    y - max_y
  } else {
    0
  }

  dx + dy
}

///|
/// Estimate geofence risk score.
pub fn geofence_risk_score(
  x: Int,
  y: Int,
  min_x: Int,
  min_y: Int,
  max_x: Int,
  max_y: Int,
  margin: Int
) -> Int {
  let inside = geofence_point_inside(x, y, min_x, min_y, max_x, max_y)
  let safe_margin = geofence_clamp_non_negative(margin)

  if !inside {
    let outside = geofence_outside_distance(x, y, min_x, min_y, max_x, max_y)
    geofence_clamp_percent(70 + outside * 3)
  } else {
    let distance = geofence_min_boundary_distance(x, y, min_x, min_y, max_x, max_y)
    if distance >= safe_margin {
      10
    } else if safe_margin <= 0 {
      10
    } else {
      geofence_clamp_percent(60 - distance * 50 / safe_margin)
    }
  }
}

///|
/// Convert geofence risk score to level.
pub fn geofence_risk_level(score: Int) -> String {
  let safe_score = geofence_clamp_percent(score)

  if safe_score >= 85 {
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
/// Check whether drone should return to field.
pub fn geofence_should_return(score: Int) -> Bool {
  geofence_clamp_percent(score) >= 60
}

///|
/// Check whether mission should pause.
pub fn geofence_should_pause(score: Int) -> Bool {
  geofence_clamp_percent(score) >= 80
}

///|
/// Recommend geofence action.
pub fn geofence_action(score: Int, inside: Bool) -> String {
  let safe_score = geofence_clamp_percent(score)

  if !inside {
    "return_to_field"
  } else if safe_score >= 80 {
    "pause_and_recenter"
  } else if safe_score >= 60 {
    "slow_down_and_turn_inward"
  } else if safe_score >= 35 {
    "watch_boundary"
  } else {
    "continue"
  }
}

///|
/// Estimate speed limit near boundary.
pub fn geofence_speed_limit_mps(score: Int, normal_speed_mps: Int) -> Int {
  let speed = geofence_clamp_non_negative(normal_speed_mps)
  let safe_score = geofence_clamp_percent(score)

  if safe_score >= 80 {
    1
  } else if safe_score >= 60 {
    if speed > 3 {
      3
    } else {
      speed
    }
  } else if safe_score >= 35 {
    if speed > 5 {
      5
    } else {
      speed
    }
  } else {
    speed
  }
}

///|
/// Estimate battery penalty caused by geofence correction.
pub fn geofence_battery_penalty(score: Int) -> Int {
  let safe_score = geofence_clamp_percent(score)

  if safe_score >= 80 {
    6
  } else if safe_score >= 60 {
    3
  } else if safe_score >= 35 {
    1
  } else {
    0
  }
}

///|
/// Estimate corrected x coordinate.
pub fn geofence_corrected_x(
  x: Int,
  min_x: Int,
  max_x: Int,
  margin: Int
) -> Int {
  let safe_margin = geofence_clamp_non_negative(margin)
  let low = min_x + safe_margin
  let high = max_x - safe_margin

  if x < low {
    low
  } else if x > high {
    high
  } else {
    x
  }
}

///|
/// Estimate corrected y coordinate.
pub fn geofence_corrected_y(
  y: Int,
  min_y: Int,
  max_y: Int,
  margin: Int
) -> Int {
  let safe_margin = geofence_clamp_non_negative(margin)
  let low = min_y + safe_margin
  let high = max_y - safe_margin

  if y < low {
    low
  } else if y > high {
    high
  } else {
    y
  }
}

///|
/// Estimate geofence health score.
pub fn geofence_health_score(score: Int, gps_quality_percent: Int) -> Int {
  let risk = geofence_clamp_percent(score)
  let gps = geofence_clamp_percent(gps_quality_percent)
  geofence_clamp_percent(100 - risk + gps / 5)
}

///|
/// Convert geofence health score to level.
pub fn geofence_health_level(score: Int) -> String {
  let safe_score = geofence_clamp_percent(score)

  if safe_score >= 85 {
    "stable"
  } else if safe_score >= 65 {
    "watch"
  } else if safe_score >= 45 {
    "weak"
  } else {
    "unsafe"
  }
}

///|
/// Print geofence module summary.
pub fn geofence_summary() -> Unit {
  let min_x = 0
  let min_y = 0
  let max_x = 300
  let max_y = 180
  let drone_x = 292
  let drone_y = 174
  let margin = 15
  let normal_speed = 7
  let gps_quality = 88

  let inside = geofence_point_inside(drone_x, drone_y, min_x, min_y, max_x, max_y)
  let near = geofence_near_boundary(drone_x, drone_y, min_x, min_y, max_x, max_y, margin)
  let min_distance = geofence_min_boundary_distance(
    drone_x,
    drone_y,
    min_x,
    min_y,
    max_x,
    max_y,
  )
  let outside_distance = geofence_outside_distance(
    drone_x,
    drone_y,
    min_x,
    min_y,
    max_x,
    max_y,
  )
  let risk = geofence_risk_score(drone_x, drone_y, min_x, min_y, max_x, max_y, margin)
  let level = geofence_risk_level(risk)
  let should_return = geofence_should_return(risk)
  let should_pause = geofence_should_pause(risk)
  let action = geofence_action(risk, inside)
  let speed_limit = geofence_speed_limit_mps(risk, normal_speed)
  let battery_penalty = geofence_battery_penalty(risk)
  let corrected_x = geofence_corrected_x(drone_x, min_x, max_x, margin)
  let corrected_y = geofence_corrected_y(drone_y, min_y, max_y, margin)
  let health = geofence_health_score(risk, gps_quality)
  let health_level = geofence_health_level(health)

  println("Geofence field: " + max_x.to_string() + " x " + max_y.to_string() + " m")
  println("Geofence drone position: (" + drone_x.to_string() + ", " + drone_y.to_string() + ")")
  println("Geofence inside field: " + inside.to_string())
  println("Geofence near boundary: " + near.to_string())
  println("Geofence min boundary distance: " + min_distance.to_string() + " m")
  println("Geofence outside distance: " + outside_distance.to_string() + " m")
  println("Geofence risk score: " + risk.to_string())
  println("Geofence risk level: " + level)
  println("Geofence should return: " + should_return.to_string())
  println("Geofence should pause: " + should_pause.to_string())
  println("Geofence action: " + action)
  println("Geofence speed limit: " + speed_limit.to_string() + " m/s")
  println("Geofence battery penalty: " + battery_penalty.to_string() + "%")
  println("Geofence corrected position: (" + corrected_x.to_string() + ", " + corrected_y.to_string() + ")")
  println("Geofence health score: " + health.to_string())
  println("Geofence health level: " + health_level)
}
