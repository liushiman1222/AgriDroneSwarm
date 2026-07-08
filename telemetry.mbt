///|
/// Telemetry module for AgriDroneSwarm.
///
/// This module provides telemetry signal quality,
/// link health, packet loss, latency, and reporting helpers.

///|
/// Telemetry link type: radio.
pub fn telemetry_link_radio() -> Int {
  0
}

///|
/// Telemetry link type: lte.
pub fn telemetry_link_lte() -> Int {
  1
}

///|
/// Telemetry link type: satellite.
pub fn telemetry_link_satellite() -> Int {
  2
}

///|
/// Telemetry link type: mesh.
pub fn telemetry_link_mesh() -> Int {
  3
}

///|
/// Convert telemetry link type to readable text.
pub fn telemetry_link_name(link : Int) -> String {
  match link {
    0 => "radio"
    1 => "lte"
    2 => "satellite"
    3 => "mesh"
    _ => "unknown"
  }
}

///|
/// Telemetry status: good.
pub fn telemetry_status_good() -> Int {
  0
}

///|
/// Telemetry status: degraded.
pub fn telemetry_status_degraded() -> Int {
  1
}

///|
/// Telemetry status: unstable.
pub fn telemetry_status_unstable() -> Int {
  2
}

///|
/// Telemetry status: lost.
pub fn telemetry_status_lost() -> Int {
  3
}

///|
/// Convert telemetry status to readable text.
pub fn telemetry_status_name(status : Int) -> String {
  match status {
    0 => "good"
    1 => "degraded"
    2 => "unstable"
    3 => "lost"
    _ => "unknown"
  }
}

///|
/// Clamp percent into 0..100.
pub fn telemetry_clamp_percent(value : Int) -> Int {
  if value < 0 {
    0
  } else if value > 100 {
    100
  } else {
    value
  }
}

///|
/// Clamp non-negative integer.
pub fn telemetry_clamp_non_negative(value : Int) -> Int {
  if value < 0 {
    0
  } else {
    value
  }
}

///|
/// Estimate signal quality from RSSI-like value.
///
/// signal_strength is expected in 0..100.
pub fn telemetry_signal_quality(signal_strength : Int) -> Int {
  telemetry_clamp_percent(signal_strength)
}

///|
/// Convert signal quality to readable level.
pub fn telemetry_signal_level_name(signal_quality : Int) -> String {
  let q = telemetry_clamp_percent(signal_quality)
  if q >= 85 {
    "excellent"
  } else if q >= 65 {
    "good"
  } else if q >= 40 {
    "weak"
  } else {
    "poor"
  }
}

///|
/// Estimate packet delivery quality.
pub fn telemetry_packet_quality(packet_loss_percent : Int) -> Int {
  let loss = telemetry_clamp_percent(packet_loss_percent)
  100 - loss
}

///|
/// Convert packet loss to readable level.
pub fn telemetry_packet_loss_name(packet_loss_percent : Int) -> String {
  let loss = telemetry_clamp_percent(packet_loss_percent)
  if loss >= 40 {
    "critical"
  } else if loss >= 20 {
    "high"
  } else if loss >= 8 {
    "medium"
  } else {
    "low"
  }
}

///|
/// Estimate latency quality.
pub fn telemetry_latency_quality(latency_ms : Int) -> Int {
  let latency = telemetry_clamp_non_negative(latency_ms)
  if latency <= 50 {
    100
  } else if latency <= 100 {
    85
  } else if latency <= 200 {
    65
  } else if latency <= 500 {
    40
  } else {
    20
  }
}

///|
/// Convert latency to readable level.
pub fn telemetry_latency_name(latency_ms : Int) -> String {
  let latency = telemetry_clamp_non_negative(latency_ms)
  if latency <= 50 {
    "real-time"
  } else if latency <= 100 {
    "fast"
  } else if latency <= 200 {
    "normal"
  } else if latency <= 500 {
    "slow"
  } else {
    "very-slow"
  }
}

///|
/// Estimate uplink quality.
pub fn telemetry_uplink_quality(
  signal_quality : Int,
  packet_loss_percent : Int,
  latency_ms : Int,
) -> Int {
  let signal = telemetry_clamp_percent(signal_quality)
  let packet = telemetry_packet_quality(packet_loss_percent)
  let latency = telemetry_latency_quality(latency_ms)
  telemetry_clamp_percent(signal * 4 / 10 + packet * 3 / 10 + latency * 3 / 10)
}

///|
/// Estimate downlink quality.
pub fn telemetry_downlink_quality(
  signal_quality : Int,
  packet_loss_percent : Int,
  latency_ms : Int,
) -> Int {
  let signal = telemetry_clamp_percent(signal_quality)
  let packet = telemetry_packet_quality(packet_loss_percent)
  let latency = telemetry_latency_quality(latency_ms)
  telemetry_clamp_percent(signal * 3 / 10 + packet * 4 / 10 + latency * 3 / 10)
}

///|
/// Estimate total telemetry health score.
pub fn telemetry_health_score(
  uplink_signal : Int,
  uplink_loss : Int,
  uplink_latency : Int,
  downlink_signal : Int,
  downlink_loss : Int,
  downlink_latency : Int,
) -> Int {
  let up = telemetry_uplink_quality(uplink_signal, uplink_loss, uplink_latency)
  let down = telemetry_downlink_quality(
    downlink_signal, downlink_loss, downlink_latency,
  )
  telemetry_clamp_percent(up * 5 / 10 + down * 5 / 10)
}

///|
/// Convert telemetry health score to status.
pub fn telemetry_status_from_health(health : Int) -> Int {
  let h = telemetry_clamp_percent(health)
  if h >= 75 {
    telemetry_status_good()
  } else if h >= 55 {
    telemetry_status_degraded()
  } else if h >= 30 {
    telemetry_status_unstable()
  } else {
    telemetry_status_lost()
  }
}

///|
/// Convert telemetry health score to readable level.
pub fn telemetry_health_name(health : Int) -> String {
  telemetry_status_name(telemetry_status_from_health(health))
}

///|
/// Check whether telemetry is usable for normal mission.
pub fn telemetry_usable_for_mission(health : Int) -> Bool {
  telemetry_clamp_percent(health) >= 55
}

///|
/// Check whether telemetry is usable for precision mission.
pub fn telemetry_usable_for_precision(health : Int, latency_ms : Int) -> Bool {
  telemetry_clamp_percent(health) >= 75 &&
  telemetry_clamp_non_negative(latency_ms) <= 150
}

///|
/// Check whether telemetry requires return-to-base.
pub fn telemetry_requires_rtb(health : Int, packet_loss_percent : Int) -> Bool {
  telemetry_clamp_percent(health) < 30 ||
  telemetry_clamp_percent(packet_loss_percent) >= 45
}

///|
/// Estimate reconnect risk score.
pub fn telemetry_reconnect_risk(
  reconnect_count : Int,
  packet_loss_percent : Int,
  signal_quality : Int,
) -> Int {
  let reconnect = telemetry_clamp_non_negative(reconnect_count)
  let loss = telemetry_clamp_percent(packet_loss_percent)
  let signal = telemetry_clamp_percent(signal_quality)
  telemetry_clamp_percent(reconnect * 8 + loss + (100 - signal) / 2)
}

///|
/// Convert reconnect risk to readable text.
pub fn telemetry_reconnect_risk_name(risk : Int) -> String {
  let r = telemetry_clamp_percent(risk)
  if r >= 80 {
    "critical"
  } else if r >= 60 {
    "high"
  } else if r >= 35 {
    "medium"
  } else {
    "low"
  }
}

///|
/// Estimate data freshness score.
pub fn telemetry_data_freshness_score(last_update_seconds : Int) -> Int {
  let age = telemetry_clamp_non_negative(last_update_seconds)
  if age <= 1 {
    100
  } else if age <= 3 {
    85
  } else if age <= 8 {
    65
  } else if age <= 20 {
    40
  } else {
    10
  }
}

///|
/// Convert data freshness to readable text.
pub fn telemetry_data_freshness_name(last_update_seconds : Int) -> String {
  let age = telemetry_clamp_non_negative(last_update_seconds)
  if age <= 1 {
    "live"
  } else if age <= 3 {
    "fresh"
  } else if age <= 8 {
    "delayed"
  } else if age <= 20 {
    "stale"
  } else {
    "expired"
  }
}

///|
/// Check whether command channel is safe.
pub fn telemetry_command_channel_safe(
  health : Int,
  latency_ms : Int,
  packet_loss_percent : Int,
) -> Bool {
  telemetry_clamp_percent(health) >= 65 &&
  telemetry_clamp_non_negative(latency_ms) <= 250 &&
  telemetry_clamp_percent(packet_loss_percent) <= 20
}

///|
/// Check whether video stream is stable.
pub fn telemetry_video_stream_stable(
  downlink_signal : Int,
  packet_loss_percent : Int,
  latency_ms : Int,
) -> Bool {
  let quality = telemetry_downlink_quality(
    downlink_signal, packet_loss_percent, latency_ms,
  )
  quality >= 60 && telemetry_clamp_percent(packet_loss_percent) <= 25
}

///|
/// Estimate recommended telemetry mode.
///
/// 0 = normal, 1 = low-bandwidth, 2 = emergency.
pub fn telemetry_recommended_mode(
  health : Int,
  packet_loss_percent : Int,
  latency_ms : Int,
) -> Int {
  let h = telemetry_clamp_percent(health)
  let loss = telemetry_clamp_percent(packet_loss_percent)
  let latency = telemetry_clamp_non_negative(latency_ms)
  if h < 30 || loss >= 45 {
    2
  } else if h < 60 || loss >= 20 || latency > 300 {
    1
  } else {
    0
  }
}

///|
/// Convert telemetry mode to readable text.
pub fn telemetry_mode_name(mode : Int) -> String {
  match mode {
    0 => "normal"
    1 => "low-bandwidth"
    2 => "emergency"
    _ => "unknown"
  }
}

///|
/// Estimate heartbeat reliability.
pub fn telemetry_heartbeat_reliability(
  expected_count : Int,
  received_count : Int,
) -> Int {
  let expected = telemetry_clamp_non_negative(expected_count)
  let received = telemetry_clamp_non_negative(received_count)
  if expected <= 0 {
    0
  } else if received >= expected {
    100
  } else {
    telemetry_clamp_percent(received * 100 / expected)
  }
}

///|
/// Convert heartbeat reliability to readable text.
pub fn telemetry_heartbeat_name(reliability : Int) -> String {
  let r = telemetry_clamp_percent(reliability)
  if r >= 95 {
    "stable"
  } else if r >= 80 {
    "minor-loss"
  } else if r >= 60 {
    "unstable"
  } else {
    "broken"
  }
}

///|
/// Estimate telemetry alert level.
pub fn telemetry_alert_level(
  health : Int,
  reconnect_risk : Int,
  heartbeat_reliability : Int,
) -> Int {
  let h = telemetry_clamp_percent(health)
  let risk = telemetry_clamp_percent(reconnect_risk)
  let heartbeat = telemetry_clamp_percent(heartbeat_reliability)
  if h < 30 || risk >= 80 || heartbeat < 60 {
    3
  } else if h < 55 || risk >= 60 || heartbeat < 80 {
    2
  } else if h < 75 || risk >= 35 || heartbeat < 95 {
    1
  } else {
    0
  }
}

///|
/// Convert telemetry alert level to readable text.
pub fn telemetry_alert_name(level : Int) -> String {
  match level {
    0 => "none"
    1 => "notice"
    2 => "warning"
    3 => "critical"
    _ => "unknown"
  }
}

///|
/// Telemetry module demo.
pub fn telemetry_summary() -> Unit {
  let link = telemetry_link_mesh()
  let up_signal = telemetry_signal_quality(78)
  let down_signal = telemetry_signal_quality(72)
  let health = telemetry_health_score(up_signal, 6, 120, down_signal, 8, 150)
  let risk = telemetry_reconnect_risk(2, 8, down_signal)
  let heartbeat = telemetry_heartbeat_reliability(100, 94)
  let alert = telemetry_alert_level(health, risk, heartbeat)
  let mode = telemetry_recommended_mode(health, 8, 150)

  println("Telemetry module:")
  println("- Link:")
  println(telemetry_link_name(link))
  println("- Signal level:")
  println(telemetry_signal_level_name(down_signal))
  println("- Health:")
  println(telemetry_health_name(health))
  println("- Reconnect risk:")
  println(telemetry_reconnect_risk_name(risk))
  println("- Heartbeat:")
  println(telemetry_heartbeat_name(heartbeat))
  println("- Alert:")
  println(telemetry_alert_name(alert))
  println("- Recommended mode:")
  println(telemetry_mode_name(mode))
}
