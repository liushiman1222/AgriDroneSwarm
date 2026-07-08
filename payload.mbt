///|
/// Payload module for AgriDroneSwarm.
/// Handles tank capacity, liquid usage, refill decision, and payload risk.

///|
/// Clamp non-negative integer.
pub fn payload_clamp_non_negative(value : Int) -> Int {
  if value < 0 {
    0
  } else {
    value
  }
}

///|
/// Clamp percent to 0..100.
pub fn payload_clamp_percent(value : Int) -> Int {
  if value < 0 {
    0
  } else if value > 100 {
    100
  } else {
    value
  }
}

///|
/// Clamp value to max capacity.
pub fn payload_clamp_capacity(value : Int, capacity : Int) -> Int {
  let safe_value = payload_clamp_non_negative(value)
  let safe_capacity = payload_clamp_non_negative(capacity)

  if safe_value > safe_capacity {
    safe_capacity
  } else {
    safe_value
  }
}

///|
/// Calculate payload percent.
pub fn payload_percent(current_liters : Int, capacity_liters : Int) -> Int {
  let current = payload_clamp_non_negative(current_liters)
  let capacity = payload_clamp_non_negative(capacity_liters)

  if capacity <= 0 {
    0
  } else {
    payload_clamp_percent(current * 100 / capacity)
  }
}

///|
/// Calculate remaining liquid after usage.
pub fn payload_remaining_liters(current_liters : Int, used_liters : Int) -> Int {
  let current = payload_clamp_non_negative(current_liters)
  let used = payload_clamp_non_negative(used_liters)

  if used >= current {
    0
  } else {
    current - used
  }
}

///|
/// Calculate how many liters are needed to refill.
pub fn payload_refill_needed_liters(
  current_liters : Int,
  capacity_liters : Int,
) -> Int {
  let current = payload_clamp_capacity(current_liters, capacity_liters)
  let capacity = payload_clamp_non_negative(capacity_liters)

  if current >= capacity {
    0
  } else {
    capacity - current
  }
}

///|
/// Estimate spray duration in minutes.
pub fn payload_spray_duration_minutes(
  current_liters : Int,
  spray_rate_liters_per_minute : Int,
) -> Int {
  let current = payload_clamp_non_negative(current_liters)
  let rate = payload_clamp_non_negative(spray_rate_liters_per_minute)

  if rate <= 0 {
    0
  } else {
    current / rate
  }
}

///|
/// Estimate liquid required for field area.
pub fn payload_required_liters(
  field_area_square_meter : Int,
  liters_per_100_square_meter : Int,
) -> Int {
  let area = payload_clamp_non_negative(field_area_square_meter)
  let rate = payload_clamp_non_negative(liters_per_100_square_meter)

  if area <= 0 || rate <= 0 {
    0
  } else {
    (area * rate + 99) / 100
  }
}

///|
/// Estimate liquid usage for planned minutes.
pub fn payload_usage_liters(
  spray_minutes : Int,
  spray_rate_liters_per_minute : Int,
) -> Int {
  let minutes = payload_clamp_non_negative(spray_minutes)
  let rate = payload_clamp_non_negative(spray_rate_liters_per_minute)

  minutes * rate
}

///|
/// Check whether payload is enough for required liters.
pub fn payload_enough(current_liters : Int, required_liters : Int) -> Bool {
  payload_clamp_non_negative(current_liters) >=
  payload_clamp_non_negative(required_liters)
}

///|
/// Check whether refill is needed.
pub fn payload_need_refill(
  current_liters : Int,
  required_liters : Int,
  reserve_liters : Int,
) -> Bool {
  let current = payload_clamp_non_negative(current_liters)
  let required = payload_clamp_non_negative(required_liters)
  let reserve = payload_clamp_non_negative(reserve_liters)

  current < required + reserve
}

///|
/// Estimate payload weight in kg.
/// Approximation: 1 liter liquid = 1 kg.
pub fn payload_weight_kg(current_liters : Int, empty_tank_kg : Int) -> Int {
  payload_clamp_non_negative(current_liters) +
  payload_clamp_non_negative(empty_tank_kg)
}

///|
/// Check whether payload weight is safe.
pub fn payload_weight_safe(
  payload_weight_kg_value : Int,
  max_payload_kg : Int,
) -> Bool {
  payload_clamp_non_negative(payload_weight_kg_value) <=
  payload_clamp_non_negative(max_payload_kg)
}

///|
/// Estimate flight speed penalty caused by payload.
pub fn payload_speed_penalty_percent(payload_percent_value : Int) -> Int {
  let percent = payload_clamp_percent(payload_percent_value)

  if percent >= 90 {
    25
  } else if percent >= 70 {
    18
  } else if percent >= 50 {
    12
  } else if percent >= 25 {
    6
  } else {
    0
  }
}

///|
/// Estimate battery penalty caused by payload.
pub fn payload_battery_penalty_percent(payload_percent_value : Int) -> Int {
  let percent = payload_clamp_percent(payload_percent_value)

  if percent >= 90 {
    12
  } else if percent >= 70 {
    8
  } else if percent >= 50 {
    5
  } else if percent >= 25 {
    2
  } else {
    0
  }
}

///|
/// Estimate payload balance score.
pub fn payload_balance_score(left_liters : Int, right_liters : Int) -> Int {
  let left = payload_clamp_non_negative(left_liters)
  let right = payload_clamp_non_negative(right_liters)
  let total = left + right

  if total <= 0 {
    100
  } else {
    let diff = if left >= right { left - right } else { right - left }
    payload_clamp_percent(100 - diff * 100 / total)
  }
}

///|
/// Estimate payload risk score.
pub fn payload_risk_score(
  payload_percent_value : Int,
  balance_score : Int,
  weight_safe : Bool,
  need_refill : Bool,
) -> Int {
  let percent = payload_clamp_percent(payload_percent_value)
  let balance = payload_clamp_percent(balance_score)

  let weight_risk = if weight_safe { 0 } else { 35 }

  let refill_risk = if need_refill { 25 } else { 0 }

  let load_risk = if percent >= 95 {
    25
  } else if percent <= 10 {
    20
  } else {
    5
  }

  let balance_risk = 100 - balance

  payload_clamp_percent(
    weight_risk + refill_risk + load_risk + balance_risk / 2,
  )
}

///|
/// Convert payload risk score to level.
pub fn payload_risk_level(score : Int) -> String {
  let safe_score = payload_clamp_percent(score)

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
/// Recommend payload action.
pub fn payload_action(
  risk_score : Int,
  need_refill : Bool,
  weight_safe : Bool,
) -> String {
  let risk = payload_clamp_percent(risk_score)

  if !weight_safe {
    "reduce_payload"
  } else if need_refill {
    "refill_before_mission"
  } else if risk >= 80 {
    "hold"
  } else if risk >= 60 {
    "inspect_payload"
  } else if risk >= 35 {
    "start_with_monitoring"
  } else {
    "start"
  }
}

///|
/// Estimate mission count before refill.
pub fn payload_mission_count_before_refill(
  current_liters : Int,
  required_per_mission_liters : Int,
) -> Int {
  let current = payload_clamp_non_negative(current_liters)
  let required = payload_clamp_non_negative(required_per_mission_liters)

  if required <= 0 {
    0
  } else {
    current / required
  }
}

///|
/// Print payload module summary.
pub fn payload_summary() -> Unit {
  let capacity = 30
  let current = 24
  let field_area = 1200
  let liters_per_100_square_meter = 2
  let spray_rate = 3
  let reserve = 4
  let empty_tank_weight = 3
  let max_payload_weight = 32
  let left_tank = 13
  let right_tank = 11

  let percent = payload_percent(current, capacity)
  let required = payload_required_liters(
    field_area, liters_per_100_square_meter,
  )
  let usage = payload_usage_liters(6, spray_rate)
  let remaining = payload_remaining_liters(current, usage)
  let refill_needed = payload_refill_needed_liters(current, capacity)
  let duration = payload_spray_duration_minutes(current, spray_rate)
  let enough = payload_enough(current, required)
  let need_refill = payload_need_refill(current, required, reserve)
  let weight = payload_weight_kg(current, empty_tank_weight)
  let weight_safe = payload_weight_safe(weight, max_payload_weight)
  let speed_penalty = payload_speed_penalty_percent(percent)
  let battery_penalty = payload_battery_penalty_percent(percent)
  let balance = payload_balance_score(left_tank, right_tank)
  let risk = payload_risk_score(percent, balance, weight_safe, need_refill)
  let level = payload_risk_level(risk)
  let action = payload_action(risk, need_refill, weight_safe)
  let mission_count = payload_mission_count_before_refill(current, required)

  println("Payload capacity: " + capacity.to_string() + " L")
  println("Payload current: " + current.to_string() + " L")
  println("Payload percent: " + percent.to_string() + "%")
  println("Payload required: " + required.to_string() + " L")
  println("Payload usage estimate: " + usage.to_string() + " L")
  println("Payload remaining after usage: " + remaining.to_string() + " L")
  println("Payload refill needed: " + refill_needed.to_string() + " L")
  println("Payload spray duration: " + duration.to_string() + " min")
  println("Payload enough: " + enough.to_string())
  println("Payload need refill: " + need_refill.to_string())
  println("Payload weight: " + weight.to_string() + " kg")
  println("Payload weight safe: " + weight_safe.to_string())
  println("Payload speed penalty: " + speed_penalty.to_string() + "%")
  println("Payload battery penalty: " + battery_penalty.to_string() + "%")
  println("Payload balance score: " + balance.to_string())
  println("Payload risk score: " + risk.to_string())
  println("Payload risk level: " + level)
  println("Payload action: " + action)
  println("Payload mission count before refill: " + mission_count.to_string())
}
