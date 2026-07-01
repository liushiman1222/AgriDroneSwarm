///|
/// Flight control module for AgriDroneSwarm.

///|
pub fn control_clamp_non_negative(value: Int) -> Int {
  if value < 0 {
    0
  } else {
    value
  }
}

///|
pub fn control_clamp_percent(value: Int) -> Int {
  if value < 0 {
    0
  } else if value > 100 {
    100
  } else {
    value
  }
}

///|
pub fn control_clamp_altitude_meters(
  altitude_meters: Int,
  max_altitude_meters: Int
) -> Int {
  let altitude = control_clamp_non_negative(altitude_meters)
  let max_altitude = control_clamp_non_negative(max_altitude_meters)

  if max_altitude <= 0 {
    0
  } else if altitude > max_altitude {
    max_altitude
  } else {
    altitude
  }
}

///|
pub fn control_clamp_speed_kmh(
  speed_kmh: Int,
  max_speed_kmh: Int
) -> Int {
  let speed = control_clamp_non_negative(speed_kmh)
  let max_speed = control_clamp_non_negative(max_speed_kmh)

  if max_speed <= 0 {
    0
  } else if speed > max_speed {
    max_speed
  } else {
    speed
  }
}

///|
pub fn control_battery_risk_level(battery_percent: Int) -> String {
  let battery = control_clamp_percent(battery_percent)

  if battery <= 10 {
    "critical"
  } else if battery <= 25 {
    "low"
  } else if battery <= 50 {
    "medium"
  } else {
    "normal"
  }
}

///|
pub fn control_signal_risk_level(signal_percent: Int) -> String {
  let signal = control_clamp_percent(signal_percent)

  if signal <= 15 {
    "critical"
  } else if signal <= 35 {
    "weak"
  } else if signal <= 60 {
    "fair"
  } else {
    "stable"
  }
}

///|
pub fn control_should_return_home(
  battery_percent: Int,
  signal_percent: Int,
  distance_to_base_meters: Int
) -> Bool {
  let battery = control_clamp_percent(battery_percent)
  let signal = control_clamp_percent(signal_percent)
  let distance = control_clamp_non_negative(distance_to_base_meters)

  battery <= 25 || signal <= 20 || distance >= 3000
}

///|
pub fn control_should_emergency_land(
  battery_percent: Int,
  signal_percent: Int,
  obstacle_distance_meters: Int
) -> Bool {
  let battery = control_clamp_percent(battery_percent)
  let signal = control_clamp_percent(signal_percent)
  let obstacle_distance = control_clamp_non_negative(obstacle_distance_meters)

  battery <= 8 || signal <= 8 || obstacle_distance <= 3
}

///|
pub fn control_altitude_status(
  altitude_meters: Int,
  min_safe_altitude_meters: Int,
  max_safe_altitude_meters: Int
) -> String {
  let altitude = control_clamp_non_negative(altitude_meters)
  let min_safe = control_clamp_non_negative(min_safe_altitude_meters)
  let max_safe = control_clamp_non_negative(max_safe_altitude_meters)

  if altitude < min_safe {
    "too_low"
  } else if max_safe > 0 && altitude > max_safe {
    "too_high"
  } else {
    "safe"
  }
}

///|
pub fn control_speed_status(
  speed_kmh: Int,
  max_safe_speed_kmh: Int
) -> String {
  let speed = control_clamp_non_negative(speed_kmh)
  let max_safe = control_clamp_non_negative(max_safe_speed_kmh)

  if max_safe <= 0 {
    "stopped"
  } else if speed > max_safe {
    "too_fast"
  } else if speed == 0 {
    "hovering"
  } else {
    "safe"
  }
}

///|
pub fn control_operation_mode(
  should_return_home: Bool,
  should_emergency_land: Bool
) -> String {
  if should_emergency_land {
    "emergency_land"
  } else if should_return_home {
    "return_home"
  } else {
    "continue_mission"
  }
}

///|
pub fn control_safety_score(
  battery_percent: Int,
  signal_percent: Int,
  altitude_safe: Bool,
  speed_safe: Bool
) -> Int {
  let battery = control_clamp_percent(battery_percent)
  let signal = control_clamp_percent(signal_percent)
  let altitude_score = if altitude_safe { 100 } else { 40 }
  let speed_score = if speed_safe { 100 } else { 40 }

  control_clamp_percent(
    battery / 4 + signal / 4 + altitude_score / 4 + speed_score / 4
  )
}

///|
pub fn control_summary() -> Unit {
  let battery = 32
  let signal = 68
  let altitude = 120
  let max_altitude = 150
  let min_safe_altitude = 30
  let speed = 42
  let max_speed = 55
  let distance_to_base = 1800
  let obstacle_distance = 20

  let safe_altitude = control_clamp_altitude_meters(altitude, max_altitude)
  let safe_speed = control_clamp_speed_kmh(speed, max_speed)
  let battery_risk = control_battery_risk_level(battery)
  let signal_risk = control_signal_risk_level(signal)
  let return_home = control_should_return_home(
    battery,
    signal,
    distance_to_base
  )
  let emergency_land = control_should_emergency_land(
    battery,
    signal,
    obstacle_distance
  )
  let altitude_status = control_altitude_status(
    safe_altitude,
    min_safe_altitude,
    max_altitude
  )
  let speed_status = control_speed_status(safe_speed, max_speed)
  let mode = control_operation_mode(return_home, emergency_land)
  let safety_score = control_safety_score(
    battery,
    signal,
    altitude_status == "safe",
    speed_status == "safe"
  )

  println("Control Summary")
  println("safe altitude meters: \{safe_altitude}")
  println("safe speed kmh: \{safe_speed}")
  println("battery risk: \{battery_risk}")
  println("signal risk: \{signal_risk}")
  println("return home: \{return_home}")
  println("emergency land: \{emergency_land}")
  println("altitude status: \{altitude_status}")
  println("speed status: \{speed_status}")
  println("operation mode: \{mode}")
  println("safety score: \{safety_score}")
}
