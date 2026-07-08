///|
/// Sensor module for AgriDroneSwarm.
///
/// This module provides sensor quality checks, crop health scoring,
/// anomaly detection, and alert level helpers.

///|
/// RGB camera sensor.
pub fn sensor_type_rgb() -> Int {
  0
}

///|
/// Multispectral sensor.
pub fn sensor_type_multispectral() -> Int {
  1
}

///|
/// Thermal sensor.
pub fn sensor_type_thermal() -> Int {
  2
}

///|
/// LiDAR sensor.
pub fn sensor_type_lidar() -> Int {
  3
}

///|
/// Soil moisture sensor.
pub fn sensor_type_soil() -> Int {
  4
}

///|
/// Convert sensor type to readable text.
pub fn sensor_type_name(kind : Int) -> String {
  match kind {
    0 => "rgb-camera"
    1 => "multispectral"
    2 => "thermal"
    3 => "lidar"
    4 => "soil-moisture"
    _ => "unknown"
  }
}

///|
/// Clamp quality into 0..100.
pub fn clamp_sensor_quality(value : Int) -> Int {
  if value < 0 {
    0
  } else if value > 100 {
    100
  } else {
    value
  }
}

///|
/// Convert sensor quality to readable level.
pub fn sensor_quality_name(quality : Int) -> String {
  let safe_quality = clamp_sensor_quality(quality)
  if safe_quality >= 85 {
    "excellent"
  } else if safe_quality >= 65 {
    "good"
  } else if safe_quality >= 40 {
    "usable"
  } else {
    "poor"
  }
}

///|
/// Check whether a sensor can be used for mission data.
pub fn sensor_usable(quality : Int) -> Bool {
  clamp_sensor_quality(quality) >= 40
}

///|
/// Estimate image clarity from sensor quality and visibility.
pub fn estimate_image_clarity(quality : Int, visibility : Int) -> Int {
  let safe_quality = clamp_sensor_quality(quality)
  let safe_visibility = clamp_visibility(visibility)
  let visibility_score = if safe_visibility >= 1000 {
    100
  } else if safe_visibility >= 500 {
    70
  } else if safe_visibility >= 300 {
    45
  } else {
    20
  }
  safe_quality * visibility_score / 100
}

///|
/// Convert image clarity to readable level.
pub fn image_clarity_name(clarity : Int) -> String {
  if clarity >= 80 {
    "clear"
  } else if clarity >= 55 {
    "acceptable"
  } else if clarity >= 30 {
    "blurred"
  } else {
    "invalid"
  }
}

///|
/// Estimate crop health score from vegetation, moisture, and temperature.
pub fn estimate_crop_health(
  vegetation_index : Int,
  soil_moisture : Int,
  temperature : Int,
) -> Int {
  let veg = clamp_sensor_quality(vegetation_index)
  let moisture = clamp_sensor_quality(soil_moisture)
  let temp_score = if temperature >= 18 && temperature <= 30 {
    100
  } else if temperature >= 10 && temperature <= 36 {
    70
  } else {
    40
  }
  veg * 5 / 10 + moisture * 3 / 10 + temp_score * 2 / 10
}

///|
/// Convert crop health score to readable level.
pub fn crop_health_name(score : Int) -> String {
  if score >= 80 {
    "healthy"
  } else if score >= 60 {
    "watch"
  } else if score >= 40 {
    "stressed"
  } else {
    "critical"
  }
}

///|
/// Detect low vegetation anomaly.
pub fn low_vegetation_detected(vegetation_index : Int) -> Bool {
  clamp_sensor_quality(vegetation_index) < 45
}

///|
/// Detect dry soil anomaly.
pub fn dry_soil_detected(soil_moisture : Int) -> Bool {
  clamp_sensor_quality(soil_moisture) < 35
}

///|
/// Detect heat stress anomaly.
pub fn heat_stress_detected(temperature : Int) -> Bool {
  temperature > 36
}

///|
/// Detect cold stress anomaly.
pub fn cold_stress_detected(temperature : Int) -> Bool {
  temperature < 8
}

///|
/// Count simple crop anomalies.
pub fn crop_anomaly_count(
  vegetation_index : Int,
  soil_moisture : Int,
  temperature : Int,
) -> Int {
  let a = if low_vegetation_detected(vegetation_index) { 1 } else { 0 }
  let b = if dry_soil_detected(soil_moisture) { 1 } else { 0 }
  let c = if heat_stress_detected(temperature) { 1 } else { 0 }
  let d = if cold_stress_detected(temperature) { 1 } else { 0 }
  a + b + c + d
}

///|
/// Estimate anomaly severity score.
pub fn anomaly_severity_score(
  vegetation_index : Int,
  soil_moisture : Int,
  temperature : Int,
) -> Int {
  let count = crop_anomaly_count(vegetation_index, soil_moisture, temperature)
  let health = estimate_crop_health(
    vegetation_index, soil_moisture, temperature,
  )
  count * 25 + (100 - health) / 2
}

///|
/// Convert anomaly severity to readable alert level.
pub fn alert_level_name(severity : Int) -> String {
  if severity >= 80 {
    "critical"
  } else if severity >= 50 {
    "high"
  } else if severity >= 25 {
    "medium"
  } else {
    "low"
  }
}

///|
/// Check whether an operator alert should be raised.
pub fn should_raise_sensor_alert(severity : Int) -> Bool {
  severity >= 50
}

///|
/// Check whether a mission requires multispectral sensor.
pub fn mission_requires_multispectral(mission_kind : Int) -> Bool {
  mission_kind == mission_type_inspection() ||
  mission_kind == mission_type_mapping()
}

///|
/// Check whether a sensor matches a mission.
pub fn sensor_matches_mission(sensor_kind : Int, mission_kind : Int) -> Bool {
  if mission_requires_multispectral(mission_kind) {
    sensor_kind == sensor_type_multispectral()
  } else if mission_kind == mission_type_spraying() {
    sensor_kind == sensor_type_rgb() ||
    sensor_kind == sensor_type_multispectral()
  } else {
    true
  }
}

///|
/// Check whether collected data quality is acceptable.
pub fn data_quality_acceptable(
  sensor_quality : Int,
  visibility : Int,
  mission_kind : Int,
  sensor_kind : Int,
) -> Bool {
  sensor_usable(sensor_quality) &&
  estimate_image_clarity(sensor_quality, visibility) >= 45 &&
  sensor_matches_mission(sensor_kind, mission_kind)
}

///|
/// Sensor module demo.
pub fn sensor_summary() -> Unit {
  let sensor = sensor_type_multispectral()
  let quality = 82
  let visibility = 1100
  let health = estimate_crop_health(72, 58, 29)
  let severity = anomaly_severity_score(72, 58, 29)

  println("Sensor module:")
  println("- Sensor types: RGB, multispectral, thermal, LiDAR, soil moisture")
  println(
    "- Data rule: usable sensor + enough clarity + mission-compatible sensor",
  )
  println(
    "- Crop rule: vegetation, moisture, and temperature form health score",
  )
  println("- Example sensor:")
  println(sensor_type_name(sensor))
  println("- Sensor quality:")
  println(sensor_quality_name(quality))
  println("- Image clarity:")
  println(image_clarity_name(estimate_image_clarity(quality, visibility)))
  println("- Crop health:")
  println(crop_health_name(health))
  println("- Alert level:")
  println(alert_level_name(severity))
}
