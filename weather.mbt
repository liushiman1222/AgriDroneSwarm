///|
/// Weather module for AgriDroneSwarm.
///
/// This module provides simple weather classification,
/// flight safety checks, spraying suitability, and risk scoring.

///|
/// Clear weather code.
pub fn weather_clear() -> Int {
  0
}

///|
/// Cloudy weather code.
pub fn weather_cloudy() -> Int {
  1
}

///|
/// Rainy weather code.
pub fn weather_rainy() -> Int {
  2
}

///|
/// Windy weather code.
pub fn weather_windy() -> Int {
  3
}

///|
/// Foggy weather code.
pub fn weather_foggy() -> Int {
  4
}

///|
/// Storm weather code.
pub fn weather_storm() -> Int {
  5
}

///|
/// Convert weather code to readable text.
pub fn weather_name(kind: Int) -> String {
  match kind {
    0 => "clear"
    1 => "cloudy"
    2 => "rainy"
    3 => "windy"
    4 => "foggy"
    5 => "storm"
    _ => "unknown"
  }
}

///|
/// Clamp wind speed into non-negative range.
pub fn clamp_wind_speed(speed: Int) -> Int {
  if speed < 0 {
    0
  } else {
    speed
  }
}

///|
/// Clamp rainfall into non-negative range.
pub fn clamp_rainfall(rainfall: Int) -> Int {
  if rainfall < 0 {
    0
  } else {
    rainfall
  }
}

///|
/// Clamp visibility into non-negative range.
pub fn clamp_visibility(visibility: Int) -> Int {
  if visibility < 0 {
    0
  } else {
    visibility
  }
}

///|
/// Classify wind speed.
pub fn wind_level_name(speed: Int) -> String {
  let safe_speed = clamp_wind_speed(speed)
  if safe_speed >= 16 {
    "dangerous"
  } else if safe_speed >= 10 {
    "strong"
  } else if safe_speed >= 5 {
    "moderate"
  } else {
    "light"
  }
}

///|
/// Classify rainfall.
pub fn rainfall_level_name(rainfall: Int) -> String {
  let safe_rain = clamp_rainfall(rainfall)
  if safe_rain >= 30 {
    "heavy"
  } else if safe_rain >= 10 {
    "moderate"
  } else if safe_rain > 0 {
    "light"
  } else {
    "none"
  }
}

///|
/// Classify visibility.
pub fn visibility_level_name(visibility: Int) -> String {
  let safe_visibility = clamp_visibility(visibility)
  if safe_visibility >= 1000 {
    "good"
  } else if safe_visibility >= 500 {
    "limited"
  } else if safe_visibility >= 200 {
    "poor"
  } else {
    "dangerous"
  }
}

///|
/// Check whether wind speed is safe for flight.
pub fn wind_safe_for_flight(speed: Int) -> Bool {
  clamp_wind_speed(speed) < 16
}

///|
/// Check whether rainfall is safe for flight.
pub fn rainfall_safe_for_flight(rainfall: Int) -> Bool {
  clamp_rainfall(rainfall) < 20
}

///|
/// Check whether visibility is safe for flight.
pub fn visibility_safe_for_flight(visibility: Int) -> Bool {
  clamp_visibility(visibility) >= 300
}

///|
/// Check whether weather kind is safe.
pub fn weather_kind_safe_for_flight(kind: Int) -> Bool {
  kind != weather_storm()
}

///|
/// Full flight safety check.
pub fn weather_safe_for_flight(
  kind: Int,
  wind_speed: Int,
  rainfall: Int,
  visibility: Int
) -> Bool {
  weather_kind_safe_for_flight(kind) &&
  wind_safe_for_flight(wind_speed) &&
  rainfall_safe_for_flight(rainfall) &&
  visibility_safe_for_flight(visibility)
}

///|
/// Check whether spraying is suitable.
pub fn weather_suitable_for_spraying(
  kind: Int,
  wind_speed: Int,
  rainfall: Int,
  visibility: Int
) -> Bool {
  let flight_ok = weather_safe_for_flight(kind, wind_speed, rainfall, visibility)
  let wind_ok = clamp_wind_speed(wind_speed) <= 6
  let rain_ok = clamp_rainfall(rainfall) == 0
  flight_ok && wind_ok && rain_ok
}

///|
/// Estimate weather risk score.
pub fn weather_risk_score(
  kind: Int,
  wind_speed: Int,
  rainfall: Int,
  visibility: Int
) -> Int {
  let wind_risk = clamp_wind_speed(wind_speed) * 3
  let rain_risk = clamp_rainfall(rainfall) * 2
  let visibility_risk = if visibility >= 1000 {
    0
  } else if visibility >= 500 {
    10
  } else if visibility >= 300 {
    25
  } else {
    50
  }
  let kind_risk = match kind {
    0 => 0
    1 => 5
    2 => 20
    3 => 25
    4 => 30
    5 => 80
    _ => 40
  }
  wind_risk + rain_risk + visibility_risk + kind_risk
}

///|
/// Convert weather risk score to readable level.
pub fn weather_risk_level_name(score: Int) -> String {
  if score >= 100 {
    "critical"
  } else if score >= 60 {
    "high"
  } else if score >= 30 {
    "medium"
  } else {
    "low"
  }
}

///|
/// Check whether weather requires mission delay.
pub fn weather_requires_delay(risk_score: Int) -> Bool {
  risk_score >= 60
}

///|
/// Check whether weather requires emergency return.
pub fn weather_requires_return(
  kind: Int,
  wind_speed: Int,
  rainfall: Int,
  visibility: Int
) -> Bool {
  !weather_safe_for_flight(kind, wind_speed, rainfall, visibility)
}

///|
/// Estimate extra battery cost caused by wind.
pub fn wind_battery_penalty(distance: Int, wind_speed: Int) -> Int {
  let safe_distance = if distance < 0 { 0 } else { distance }
  let safe_wind = clamp_wind_speed(wind_speed)
  safe_distance * safe_wind / 10
}

///|
/// Estimate weather-adjusted flight battery cost.
pub fn weather_adjusted_flight_cost(distance: Int, wind_speed: Int) -> Int {
  estimate_flight_cost(distance) + wind_battery_penalty(distance, wind_speed)
}

///|
/// Check whether a mission is weather compatible.
pub fn mission_weather_compatible(
  mission_kind: Int,
  weather_kind: Int,
  wind_speed: Int,
  rainfall: Int,
  visibility: Int
) -> Bool {
  if mission_kind == mission_type_spraying() {
    weather_suitable_for_spraying(weather_kind, wind_speed, rainfall, visibility)
  } else {
    weather_safe_for_flight(weather_kind, wind_speed, rainfall, visibility)
  }
}

///|
/// Weather module demo.
pub fn weather_summary() -> Unit {
  let kind = weather_cloudy()
  let wind = 5
  let rain = 0
  let visibility = 1200
  let risk = weather_risk_score(kind, wind, rain, visibility)

  println("Weather module:")
  println("- Weather types: clear, cloudy, rainy, windy, foggy, storm")
  println("- Flight rule: no storm, safe wind, safe rain, enough visibility")
  println("- Spraying rule: flight-safe, low wind, and no rain")
  println("- Example weather:")
  println(weather_name(kind))
  println("- Wind level:")
  println(wind_level_name(wind))
  println("- Rainfall level:")
  println(rainfall_level_name(rain))
  println("- Visibility level:")
  println(visibility_level_name(visibility))
  println("- Risk level:")
  println(weather_risk_level_name(risk))
}
