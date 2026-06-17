///|
/// Event log module for AgriDroneSwarm.

///|
pub fn event_log_clamp_non_negative(value: Int) -> Int {
  if value < 0 {
    0
  } else {
    value
  }
}

///|
pub fn event_log_clamp_percent(value: Int) -> Int {
  if value < 0 {
    0
  } else if value > 100 {
    100
  } else {
    value
  }
}

///|
pub fn event_log_severity_score(event_type: String) -> Int {
  if event_type == "emergency_land" {
    100
  } else if event_type == "battery_critical" {
    95
  } else if event_type == "signal_lost" {
    90
  } else if event_type == "obstacle_near" {
    80
  } else if event_type == "return_home" {
    70
  } else if event_type == "spray_error" {
    60
  } else if event_type == "mission_paused" {
    40
  } else if event_type == "mission_started" {
    20
  } else if event_type == "mission_completed" {
    10
  } else {
    30
  }
}

///|
pub fn event_log_category(event_type: String) -> String {
  if event_type == "emergency_land" ||
     event_type == "battery_critical" ||
     event_type == "signal_lost" ||
     event_type == "obstacle_near" {
    "alert"
  } else if event_type == "return_home" ||
            event_type == "mission_paused" ||
            event_type == "mission_started" ||
            event_type == "mission_completed" {
    "mission"
  } else if event_type == "spray_on" ||
            event_type == "spray_off" ||
            event_type == "spray_error" {
    "spray"
  } else {
    "system"
  }
}

///|
pub fn event_log_requires_operator_ack(event_type: String) -> Bool {
  let severity = event_log_severity_score(event_type)
  severity >= 80
}

///|
pub fn event_log_retention_days(event_type: String) -> Int {
  let severity = event_log_severity_score(event_type)

  if severity >= 90 {
    365
  } else if severity >= 70 {
    180
  } else if severity >= 40 {
    90
  } else {
    30
  }
}

///|
pub fn event_log_priority_label(severity_score: Int) -> String {
  let severity = event_log_clamp_percent(severity_score)

  if severity >= 90 {
    "critical"
  } else if severity >= 70 {
    "high"
  } else if severity >= 40 {
    "medium"
  } else {
    "low"
  }
}

///|
pub fn event_log_should_notify(
  event_type: String,
  affected_drones: Int
) -> Bool {
  let severity = event_log_severity_score(event_type)
  let affected = event_log_clamp_non_negative(affected_drones)

  severity >= 70 || affected >= 3
}

///|
pub fn event_log_audit_score(
  severity_score: Int,
  affected_drones: Int,
  operator_acknowledged: Bool
) -> Int {
  let severity = event_log_clamp_percent(severity_score)
  let affected = event_log_clamp_non_negative(affected_drones)
  let ack_score = if operator_acknowledged { 20 } else { 0 }

  event_log_clamp_percent(severity + affected * 5 + ack_score)
}

///|
pub fn event_log_status(
  severity_score: Int,
  operator_acknowledged: Bool
) -> String {
  let severity = event_log_clamp_percent(severity_score)

  if severity >= 80 && !operator_acknowledged {
    "pending_ack"
  } else if severity >= 80 {
    "acknowledged_alert"
  } else if severity >= 40 {
    "recorded"
  } else {
    "archived"
  }
}

///|
pub fn event_log_format_message(
  event_type: String,
  drone_id: String,
  minute: Int
) -> String {
  let safe_minute = event_log_clamp_non_negative(minute)
  "event=\{event_type}, drone=\{drone_id}, minute=\{safe_minute}"
}

///|
pub fn event_log_summary() -> Unit {
  let event_type = "battery_critical"
  let drone_id = "DR-07"
  let minute = 128
  let affected_drones = 2
  let operator_acknowledged = false

  let severity = event_log_severity_score(event_type)
  let category = event_log_category(event_type)
  let requires_ack = event_log_requires_operator_ack(event_type)
  let retention_days = event_log_retention_days(event_type)
  let priority = event_log_priority_label(severity)
  let should_notify = event_log_should_notify(event_type, affected_drones)
  let audit_score = event_log_audit_score(
    severity,
    affected_drones,
    operator_acknowledged
  )
  let status = event_log_status(severity, operator_acknowledged)
  let message = event_log_format_message(event_type, drone_id, minute)

  println("Event Log Summary")
  println("event type: \{event_type}")
  println("category: \{category}")
  println("severity: \{severity}")
  println("priority: \{priority}")
  println("requires ack: \{requires_ack}")
  println("retention days: \{retention_days}")
  println("should notify: \{should_notify}")
  println("audit score: \{audit_score}")
  println("status: \{status}")
  println("message: \{message}")
}
