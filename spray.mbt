///|
/// Spray module for AgriDroneSwarm.
/// Estimate spray mode, liquid usage, nozzle flow, weather safety,
/// coverage, refill requirement, and spray quality.

///|
/// Spray mode: off.
pub fn spray_mode_off() -> Int {
  0
}

///|
/// Spray mode: low.
pub fn spray_mode_low() -> Int {
  1
}

///|
/// Spray mode: normal.
pub fn spray_mode_normal() -> Int {
  2
}

///|
/// Spray mode: high.
pub fn spray_mode_high() -> Int {
  3
}

///|
/// Spray mode name.
pub fn spray_mode_name(mode: Int) -> String {
  match mode {
    0 => "off"
    1 => "low"
    2 => "normal"
    3 => "high"
    _ => "unknown"
  }
}

///|
/// Nozzle type: mist.
pub fn spray_nozzle_mist() -> Int {
  1
}

///|
/// Nozzle type: fan.
pub fn spray_nozzle_fan() -> Int {
  2
}

///|
/// Nozzle type: cone.
pub fn spray_nozzle_cone() -> Int {
  3
}

///|
/// Nozzle type name.
pub fn spray_nozzle_name(nozzle: Int) -> String {
  match nozzle {
    1 => "mist"
    2 => "fan"
    3 => "cone"
    _ => "unknown"
  }
}

///|
/// Clamp non-negative integer.
pub fn spray_clamp_non_negative(value: Int) -> Int {
  if value < 0 {
    0
  } else {
    value
  }
}

///|
/// Clamp percent to 0..100.
pub fn spray_clamp_percent(value: Int) -> Int {
  if value < 0 {
    0
  } else if value > 100 {
    100
  } else {
    value
  }
}

///|
/// Estimate base liquid flow per minute.
pub fn spray_base_flow_liter_per_minute(mode: Int) -> Int {
  if mode == spray_mode_off() {
    0
  } else if mode == spray_mode_low() {
    1
  } else if mode == spray_mode_normal() {
    2
  } else if mode == spray_mode_high() {
    3
  } else {
    1
  }
}

///|
/// Estimate nozzle flow bonus.
pub fn spray_nozzle_flow_bonus(nozzle: Int) -> Int {
  if nozzle == spray_nozzle_mist() {
    0
  } else if nozzle == spray_nozzle_fan() {
    1
  } else if nozzle == spray_nozzle_cone() {
    2
  } else {
    0
  }
}

///|
/// Estimate total liquid flow per minute.
pub fn spray_flow_liter_per_minute(mode: Int, nozzle: Int) -> Int {
  spray_base_flow_liter_per_minute(mode) + spray_nozzle_flow_bonus(nozzle)
}

///|
/// Estimate spray width in meters.
pub fn spray_width_meters(nozzle: Int, altitude_meters: Int) -> Int {
  let altitude = spray_clamp_non_negative(altitude_meters)
  let base = if nozzle == spray_nozzle_mist() {
    3
  } else if nozzle == spray_nozzle_fan() {
    5
  } else if nozzle == spray_nozzle_cone() {
    4
  } else {
    3
  }
  base + altitude / 3
}

///|
/// Estimate recommended spray speed.
pub fn spray_recommended_speed_mps(mode: Int, wind_speed: Int) -> Int {
  let wind = spray_clamp_non_negative(wind_speed)
  let base = if mode == spray_mode_low() {
    7
  } else if mode == spray_mode_normal() {
    5
  } else if mode == spray_mode_high() {
    4
  } else {
    6
  }

  if wind >= 10 {
    if base > 2 {
      base - 2
    } else {
      1
    }
  } else if wind >= 6 {
    if base > 1 {
      base - 1
    } else {
      1
    }
  } else {
    base
  }
}

///|
/// Check whether wind is safe for spraying.
pub fn spray_wind_safe(wind_speed: Int) -> Bool {
  spray_clamp_non_negative(wind_speed) <= 10
}

///|
/// Check whether temperature is safe for spraying.
pub fn spray_temperature_safe(temperature_c: Int) -> Bool {
  temperature_c >= 5 && temperature_c <= 35
}

///|
/// Check whether humidity is safe for spraying.
pub fn spray_humidity_safe(humidity_percent: Int) -> Bool {
  let humidity = spray_clamp_percent(humidity_percent)
  humidity >= 30 && humidity <= 90
}

///|
/// Check whether weather is safe for spraying.
pub fn spray_weather_safe(
  wind_speed: Int,
  temperature_c: Int,
  humidity_percent: Int
) -> Bool {
  spray_wind_safe(wind_speed) &&
  spray_temperature_safe(temperature_c) &&
  spray_humidity_safe(humidity_percent)
}

///|
/// Estimate liquid required for area.
pub fn spray_liquid_required_liter(
  area_square_meter: Int,
  dose_liter_per_1000_square_meter: Int
) -> Int {
  let area = spray_clamp_non_negative(area_square_meter)
  let dose = spray_clamp_non_negative(dose_liter_per_1000_square_meter)
  area * dose / 1000
}

///|
/// Estimate spray duration in minutes.
pub fn spray_duration_minutes(
  liquid_liter: Int,
  mode: Int,
  nozzle: Int
) -> Int {
  let liquid = spray_clamp_non_negative(liquid_liter)
  let flow = spray_flow_liter_per_minute(mode, nozzle)
  if flow <= 0 {
    0
  } else {
    (liquid + flow - 1) / flow
  }
}

///|
/// Estimate area covered per minute.
pub fn spray_area_per_minute(speed_mps: Int, width_meters: Int) -> Int {
  let speed = spray_clamp_non_negative(speed_mps)
  let width = spray_clamp_non_negative(width_meters)
  speed * width * 60
}

///|
/// Estimate coverage percent.
pub fn spray_coverage_percent(sprayed_area: Int, field_area: Int) -> Int {
  let sprayed = spray_clamp_non_negative(sprayed_area)
  let field = spray_clamp_non_negative(field_area)
  if field <= 0 {
    0
  } else {
    spray_clamp_percent(sprayed * 100 / field)
  }
}

///|
/// Estimate remaining liquid after spraying.
pub fn spray_remaining_liter(tank_liter: Int, used_liter: Int) -> Int {
  let tank = spray_clamp_non_negative(tank_liter)
  let used = spray_clamp_non_negative(used_liter)
  if used >= tank {
    0
  } else {
    tank - used
  }
}

///|
/// Check whether tank has enough liquid.
pub fn spray_tank_enough(tank_liter: Int, required_liter: Int) -> Bool {
  spray_clamp_non_negative(tank_liter) >= spray_clamp_non_negative(required_liter)
}

///|
/// Estimate refill requirement.
pub fn spray_refill_required(tank_liter: Int, required_liter: Int) -> Bool {
  !spray_tank_enough(tank_liter, required_liter)
}

///|
/// Estimate refill amount.
pub fn spray_refill_amount_liter(tank_liter: Int, required_liter: Int) -> Int {
  let tank = spray_clamp_non_negative(tank_liter)
  let required = spray_clamp_non_negative(required_liter)
  if required > tank {
    required - tank
  } else {
    0
  }
}

///|
/// Estimate spray quality score.
pub fn spray_quality_score(
  wind_speed: Int,
  temperature_c: Int,
  humidity_percent: Int,
  mode: Int
) -> Int {
  let mut score = 100

  if !spray_wind_safe(wind_speed) {
    score = score - 30
  } else if wind_speed >= 7 {
    score = score - 10
  }

  if !spray_temperature_safe(temperature_c) {
    score = score - 20
  }

  if !spray_humidity_safe(humidity_percent) {
    score = score - 15
  }

  if mode == spray_mode_high() {
    score = score - 5
  }

  spray_clamp_percent(score)
}

///|
/// Convert spray quality score to level.
pub fn spray_quality_level(score: Int) -> String {
  let safe_score = spray_clamp_percent(score)
  if safe_score >= 85 {
    "excellent"
  } else if safe_score >= 70 {
    "good"
  } else if safe_score >= 50 {
    "limited"
  } else {
    "unsafe"
  }
}

///|
/// Check whether spray mission can start.
pub fn spray_can_start(
  tank_liter: Int,
  required_liter: Int,
  wind_speed: Int,
  temperature_c: Int,
  humidity_percent: Int
) -> Bool {
  spray_tank_enough(tank_liter, required_liter) &&
  spray_weather_safe(wind_speed, temperature_c, humidity_percent)
}

///|
/// Print spray module summary.
pub fn spray_summary() -> Unit {
  let field_area = 12000
  let dose = 6
  let tank = 90
  let mode = spray_mode_normal()
  let nozzle = spray_nozzle_fan()
  let altitude = 6
  let wind = 7
  let temperature = 29
  let humidity = 62

  let required = spray_liquid_required_liter(field_area, dose)
  let flow = spray_flow_liter_per_minute(mode, nozzle)
  let duration = spray_duration_minutes(required, mode, nozzle)
  let width = spray_width_meters(nozzle, altitude)
  let speed = spray_recommended_speed_mps(mode, wind)
  let area_per_minute = spray_area_per_minute(speed, width)
  let sprayed_area = area_per_minute * duration
  let coverage = spray_coverage_percent(sprayed_area, field_area)
  let remaining = spray_remaining_liter(tank, required)
  let refill = spray_refill_required(tank, required)
  let refill_amount = spray_refill_amount_liter(tank, required)
  let weather_ok = spray_weather_safe(wind, temperature, humidity)
  let quality = spray_quality_score(wind, temperature, humidity, mode)
  let can_start = spray_can_start(tank, required, wind, temperature, humidity)

  println("Spray mode: " + spray_mode_name(mode))
  println("Spray nozzle: " + spray_nozzle_name(nozzle))
  println("Spray field area: " + field_area.to_string() + " m2")
  println("Spray required liquid: " + required.to_string() + " L")
  println("Spray tank liquid: " + tank.to_string() + " L")
  println("Spray flow: " + flow.to_string() + " L/min")
  println("Spray duration: " + duration.to_string() + " min")
  println("Spray width: " + width.to_string() + " m")
  println("Spray speed: " + speed.to_string() + " m/s")
  println("Spray area per minute: " + area_per_minute.to_string() + " m2")
  println("Spray estimated coverage: " + coverage.to_string() + "%")
  println("Spray remaining liquid: " + remaining.to_string() + " L")
  println("Spray refill required: " + refill.to_string())
  println("Spray refill amount: " + refill_amount.to_string() + " L")
  println("Spray weather safe: " + weather_ok.to_string())
  println("Spray quality score: " + quality.to_string())
  println("Spray quality level: " + spray_quality_level(quality))
  println("Spray can start: " + can_start.to_string())
}
