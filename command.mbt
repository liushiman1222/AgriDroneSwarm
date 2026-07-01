///|
/// Command module for AgriDroneSwarm.

///|
pub fn command_clamp_non_negative(value: Int) -> Int {
  if value < 0 {
    0
  } else {
    value
  }
}

///|
pub fn command_clamp_percent(value: Int) -> Int {
  if value < 0 {
    0
  } else if value > 100 {
    100
  } else {
    value
  }
}

///|
pub fn command_priority(command: String) -> Int {
  if command == "emergency_land" {
    100
  } else if command == "return_home" {
    90
  } else if command == "land" {
    80
  } else if command == "pause" {
    70
  } else if command == "resume" {
    60
  } else if command == "spray_off" {
    55
  } else if command == "spray_on" {
    50
  } else if command == "takeoff" {
    40
  } else {
    10
  }
}

///|
pub fn command_is_emergency(command: String) -> Bool {
  command == "emergency_land" || command == "return_home"
}

///|
pub fn command_requires_airborne(command: String) -> Bool {
  command == "pause" ||
  command == "resume" ||
  command == "return_home" ||
  command == "spray_on" ||
  command == "spray_off"
}

///|
pub fn command_can_execute(
  command: String,
  is_airborne: Bool,
  battery_percent: Int,
  signal_percent: Int
) -> Bool {
  let battery = command_clamp_percent(battery_percent)
  let signal = command_clamp_percent(signal_percent)

  if command == "takeoff" {
    battery >= 30 && signal >= 40 && !is_airborne
  } else if command == "emergency_land" {
    is_airborne
  } else if command_requires_airborne(command) {
    is_airborne && battery > 5 && signal > 5
  } else if command == "land" {
    is_airborne
  } else {
    false
  }
}

///|
pub fn command_next_state(
  command: String,
  current_state: String
) -> String {
  if command == "takeoff" && current_state == "idle" {
    "airborne"
  } else if command == "pause" && current_state == "airborne" {
    "paused"
  } else if command == "resume" && current_state == "paused" {
    "airborne"
  } else if command == "return_home" {
    "returning"
  } else if command == "land" {
    "landed"
  } else if command == "emergency_land" {
    "emergency_landing"
  } else {
    current_state
  }
}

///|
pub fn command_spray_state(
  command: String,
  current_spray_enabled: Bool
) -> Bool {
  if command == "spray_on" {
    true
  } else if command == "spray_off" {
    false
  } else {
    current_spray_enabled
  }
}

///|
pub fn command_ack_timeout_ms(command: String) -> Int {
  if command_is_emergency(command) {
    300
  } else if command == "land" {
    500
  } else if command == "takeoff" {
    700
  } else {
    1000
  }
}

///|
pub fn command_retry_limit(command: String) -> Int {
  if command_is_emergency(command) {
    5
  } else if command == "takeoff" || command == "land" {
    3
  } else {
    2
  }
}

///|
pub fn command_delivery_score(
  signal_percent: Int,
  retry_count: Int,
  ack_timeout_ms: Int
) -> Int {
  let signal = command_clamp_percent(signal_percent)
  let retries = command_clamp_non_negative(retry_count)
  let timeout = command_clamp_non_negative(ack_timeout_ms)

  let retry_penalty = retries * 8
  let timeout_penalty = timeout / 200

  command_clamp_percent(signal - retry_penalty - timeout_penalty)
}

///|
pub fn command_status(
  can_execute: Bool,
  delivery_score: Int
) -> String {
  let score = command_clamp_percent(delivery_score)

  if !can_execute {
    "rejected"
  } else if score >= 75 {
    "ready"
  } else if score >= 45 {
    "delayed"
  } else {
    "risky"
  }
}

///|
pub fn command_summary() -> Unit {
  let command = "return_home"
  let current_state = "airborne"
  let is_airborne = true
  let spray_enabled = true
  let battery = 28
  let signal = 72
  let retry_count = 1

  let priority = command_priority(command)
  let emergency = command_is_emergency(command)
  let requires_airborne = command_requires_airborne(command)
  let can_execute = command_can_execute(
    command,
    is_airborne,
    battery,
    signal
  )
  let next_state = command_next_state(command, current_state)
  let next_spray = command_spray_state(command, spray_enabled)
  let ack_timeout = command_ack_timeout_ms(command)
  let retry_limit = command_retry_limit(command)
  let delivery_score = command_delivery_score(
    signal,
    retry_count,
    ack_timeout
  )
  let status = command_status(can_execute, delivery_score)

  println("Command Summary")
  println("command: \{command}")
  println("priority: \{priority}")
  println("emergency: \{emergency}")
  println("requires airborne: \{requires_airborne}")
  println("can execute: \{can_execute}")
  println("next state: \{next_state}")
  println("spray enabled after command: \{next_spray}")
  println("ack timeout ms: \{ack_timeout}")
  println("retry limit: \{retry_limit}")
  println("delivery score: \{delivery_score}")
  println("status: \{status}")
}
