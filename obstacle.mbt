///|
/// Obstacle module for AgriDroneSwarm.
/// Handles obstacle risk, safe distance, avoidance action, and route penalty.

///|
/// Obstacle type: unknown.
pub fn obstacle_type_unknown() -> Int {
  0
}

///|
/// Obstacle type: tree.
pub fn obstacle_type_tree() -> Int {
  1
}

///|
/// Obstacle type: pole.
pub fn obstacle_type_pole() -> Int {
  2
}

///|
/// Obstacle type: wire.
pub fn obstacle_type_wire() -> Int {
  3
}

///|
/// Obstacle type: building.
pub fn obstacle_type_building() -> Int {
  4
}

///|
/// Obstacle type: human.
pub fn obstacle_type_human() -> Int {
  5
}

///|
/// Obstacle type name.
pub fn obstacle_type_name(kind : Int) -> String {
  match kind {
    1 => "tree"
    2 => "pole"
    3 => "wire"
    4 => "building"
    5 => "human"
    _ => "unknown"
  }
}

///|
/// Clamp non-negative value.
pub fn obstacle_clamp_non_negative(value : Int) -> Int {
  if value < 0 {
    0
  } else {
    value
  }
}

///|
/// Clamp percent value.
pub fn obstacle_clamp_percent(value : Int) -> Int {
  if value < 0 {
    0
  } else if value > 100 {
    100
  } else {
    value
  }
}

///|
/// Base danger score by obstacle type.
pub fn obstacle_base_danger(kind : Int) -> Int {
  match kind {
    1 => 35
    2 => 45
    3 => 80
    4 => 60
    5 => 90
    _ => 30
  }
}

///|
/// Recommended safe distance in meters.
pub fn obstacle_safe_distance_meters(kind : Int) -> Int {
  match kind {
    1 => 8
    2 => 10
    3 => 18
    4 => 15
    5 => 25
    _ => 10
  }
}

///|
/// Distance risk score.
pub fn obstacle_distance_risk(
  distance_meters : Int,
  safe_distance_meters : Int,
) -> Int {
  let distance = obstacle_clamp_non_negative(distance_meters)
  let safe = obstacle_clamp_non_negative(safe_distance_meters)

  if safe <= 0 {
    0
  } else if distance >= safe {
    0
  } else {
    obstacle_clamp_percent((safe - distance) * 100 / safe)
  }
}

///|
/// Altitude risk score.
pub fn obstacle_altitude_risk(
  drone_altitude_meters : Int,
  obstacle_height_meters : Int,
) -> Int {
  let altitude = obstacle_clamp_non_negative(drone_altitude_meters)
  let height = obstacle_clamp_non_negative(obstacle_height_meters)

  if altitude > height + 5 {
    0
  } else if altitude > height {
    30
  } else {
    70
  }
}

///|
/// Estimate obstacle risk score.
pub fn obstacle_risk_score(
  kind : Int,
  distance_meters : Int,
  drone_altitude_meters : Int,
  obstacle_height_meters : Int,
) -> Int {
  let base = obstacle_base_danger(kind)
  let safe_distance = obstacle_safe_distance_meters(kind)
  let distance_risk = obstacle_distance_risk(distance_meters, safe_distance)
  let altitude_risk = obstacle_altitude_risk(
    drone_altitude_meters, obstacle_height_meters,
  )

  obstacle_clamp_percent((base + distance_risk + altitude_risk) / 3)
}

///|
/// Risk level name.
pub fn obstacle_risk_level(score : Int) -> String {
  let safe_score = obstacle_clamp_percent(score)

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
/// Check whether obstacle requires avoidance.
pub fn obstacle_requires_avoidance(score : Int) -> Bool {
  obstacle_clamp_percent(score) >= 50
}

///|
/// Recommended avoidance action.
pub fn obstacle_avoidance_action(
  kind : Int,
  score : Int,
  distance_meters : Int,
) -> String {
  let safe_score = obstacle_clamp_percent(score)
  let distance = obstacle_clamp_non_negative(distance_meters)

  if safe_score >= 80 {
    "stop_and_replan"
  } else if kind == obstacle_type_wire() {
    "climb_and_replan"
  } else if kind == obstacle_type_human() {
    "stop_and_wait"
  } else if distance <= 5 {
    "slow_down_and_turn"
  } else if safe_score >= 50 {
    "turn_around"
  } else {
    "continue"
  }
}

///|
/// Estimate route penalty caused by obstacle.
pub fn obstacle_route_penalty_minutes(
  score : Int,
  avoidance_required : Bool,
) -> Int {
  let safe_score = obstacle_clamp_percent(score)

  if !avoidance_required {
    0
  } else if safe_score >= 80 {
    8
  } else if safe_score >= 60 {
    5
  } else {
    2
  }
}

///|
/// Check whether path is safe.
pub fn obstacle_path_safe(score : Int) -> Bool {
  obstacle_clamp_percent(score) < 60
}

///|
/// Estimate battery cost for avoidance.
pub fn obstacle_avoidance_battery_cost(score : Int) -> Int {
  let safe_score = obstacle_clamp_percent(score)

  if safe_score >= 80 {
    8
  } else if safe_score >= 60 {
    5
  } else if safe_score >= 35 {
    2
  } else {
    0
  }
}

///|
/// Estimate recommended altitude after avoidance.
pub fn obstacle_recommended_altitude(
  kind : Int,
  current_altitude_meters : Int,
  obstacle_height_meters : Int,
) -> Int {
  let current = obstacle_clamp_non_negative(current_altitude_meters)
  let height = obstacle_clamp_non_negative(obstacle_height_meters)

  let margin = if kind == obstacle_type_wire() {
    12
  } else if kind == obstacle_type_building() {
    10
  } else {
    6
  }

  let target = height + margin

  if current >= target {
    current
  } else {
    target
  }
}

///|
/// Check sensor confidence.
pub fn obstacle_sensor_confidence_ok(confidence_percent : Int) -> Bool {
  obstacle_clamp_percent(confidence_percent) >= 70
}

///|
/// Estimate final safety score.
pub fn obstacle_safety_score(
  risk_score : Int,
  sensor_confidence_percent : Int,
) -> Int {
  let risk = obstacle_clamp_percent(risk_score)
  let confidence = obstacle_clamp_percent(sensor_confidence_percent)
  obstacle_clamp_percent(100 - risk + confidence / 5)
}

///|
/// Safety level name.
pub fn obstacle_safety_level(score : Int) -> String {
  let safe_score = obstacle_clamp_percent(score)

  if safe_score >= 85 {
    "safe"
  } else if safe_score >= 65 {
    "watch"
  } else if safe_score >= 45 {
    "caution"
  } else {
    "danger"
  }
}

///|
/// Print obstacle module summary.
pub fn obstacle_summary() -> Unit {
  let kind = obstacle_type_wire()
  let distance = 9
  let drone_altitude = 12
  let obstacle_height = 16
  let sensor_confidence = 82

  let safe_distance = obstacle_safe_distance_meters(kind)
  let risk = obstacle_risk_score(
    kind, distance, drone_altitude, obstacle_height,
  )
  let risk_level = obstacle_risk_level(risk)
  let avoid = obstacle_requires_avoidance(risk)
  let action = obstacle_avoidance_action(kind, risk, distance)
  let penalty = obstacle_route_penalty_minutes(risk, avoid)
  let battery_cost = obstacle_avoidance_battery_cost(risk)
  let target_altitude = obstacle_recommended_altitude(
    kind, drone_altitude, obstacle_height,
  )
  let path_safe = obstacle_path_safe(risk)
  let confidence_ok = obstacle_sensor_confidence_ok(sensor_confidence)
  let safety = obstacle_safety_score(risk, sensor_confidence)
  let safety_level = obstacle_safety_level(safety)

  println("Obstacle type: " + obstacle_type_name(kind))
  println("Obstacle distance: " + distance.to_string() + " m")
  println("Obstacle safe distance: " + safe_distance.to_string() + " m")
  println("Obstacle height: " + obstacle_height.to_string() + " m")
  println("Drone altitude: " + drone_altitude.to_string() + " m")
  println("Obstacle risk score: " + risk.to_string())
  println("Obstacle risk level: " + risk_level)
  println("Obstacle avoidance required: " + avoid.to_string())
  println("Obstacle action: " + action)
  println("Obstacle route penalty: " + penalty.to_string() + " min")
  println("Obstacle battery cost: " + battery_cost.to_string() + "%")
  println(
    "Obstacle recommended altitude: " + target_altitude.to_string() + " m",
  )
  println("Obstacle path safe: " + path_safe.to_string())
  println("Obstacle sensor confidence ok: " + confidence_ok.to_string())
  println("Obstacle safety score: " + safety.to_string())
  println("Obstacle safety level: " + safety_level)
}
