///|
/// Scheduler module for AgriDroneSwarm.
///
/// This module provides simple scheduling scores, dispatch rules,
/// queue state helpers, and time-window checks.

///|
/// Waiting task state.
pub fn schedule_state_waiting() -> Int {
  0
}

///|
/// Ready task state.
pub fn schedule_state_ready() -> Int {
  1
}

///|
/// Running task state.
pub fn schedule_state_running() -> Int {
  2
}

///|
/// Paused task state.
pub fn schedule_state_paused() -> Int {
  3
}

///|
/// Finished task state.
pub fn schedule_state_finished() -> Int {
  4
}

///|
/// Cancelled task state.
pub fn schedule_state_cancelled() -> Int {
  5
}

///|
/// Convert schedule state to readable text.
pub fn schedule_state_name(state : Int) -> String {
  match state {
    0 => "waiting"
    1 => "ready"
    2 => "running"
    3 => "paused"
    4 => "finished"
    5 => "cancelled"
    _ => "unknown"
  }
}

///|
/// Check whether a task is active.
pub fn is_active_schedule_state(state : Int) -> Bool {
  state == schedule_state_ready() ||
  state == schedule_state_running() ||
  state == schedule_state_paused()
}

///|
/// Check whether a task is closed.
pub fn is_closed_schedule_state(state : Int) -> Bool {
  state == schedule_state_finished() || state == schedule_state_cancelled()
}

///|
/// Clamp queue index to non-negative value.
pub fn clamp_queue_index(index : Int) -> Int {
  if index < 0 {
    0
  } else {
    index
  }
}

///|
/// Estimate waiting penalty.
pub fn waiting_penalty(waiting_minutes : Int) -> Int {
  let safe_wait = if waiting_minutes < 0 { 0 } else { waiting_minutes }
  safe_wait / 5
}

///|
/// Estimate deadline urgency bonus.
pub fn deadline_bonus(minutes_left : Int) -> Int {
  if minutes_left <= 0 {
    80
  } else if minutes_left <= 10 {
    60
  } else if minutes_left <= 30 {
    35
  } else if minutes_left <= 60 {
    15
  } else {
    0
  }
}

///|
/// Estimate scheduling score.
pub fn schedule_score(
  priority : Int,
  workload : Int,
  waiting_minutes : Int,
  minutes_left : Int,
) -> Int {
  let base = mission_score(priority, workload)
  base + waiting_penalty(waiting_minutes) + deadline_bonus(minutes_left)
}

///|
/// Decide whether task A should run before task B.
pub fn should_run_before(
  score_a : Int,
  score_b : Int,
  priority_a : Int,
  priority_b : Int,
) -> Bool {
  if score_a > score_b {
    true
  } else if score_a < score_b {
    false
  } else {
    clamp_mission_priority(priority_a) >= clamp_mission_priority(priority_b)
  }
}

///|
/// Check whether a time is inside a time window.
pub fn in_time_window(
  now_minute : Int,
  start_minute : Int,
  end_minute : Int,
) -> Bool {
  now_minute >= start_minute && now_minute <= end_minute
}

///|
/// Check whether dispatch is allowed now.
pub fn dispatch_window_open(
  now_minute : Int,
  start_minute : Int,
  end_minute : Int,
) -> Bool {
  in_time_window(now_minute, start_minute, end_minute)
}

///|
/// Estimate dispatch delay.
pub fn estimate_dispatch_delay(now_minute : Int, start_minute : Int) -> Int {
  if now_minute >= start_minute {
    0
  } else {
    start_minute - now_minute
  }
}

///|
/// Check whether a task can be started.
pub fn can_start_scheduled_task(
  state : Int,
  now_minute : Int,
  start_minute : Int,
  end_minute : Int,
  available_drones : Int,
  workload : Int,
) -> Bool {
  state == schedule_state_ready() &&
  dispatch_window_open(now_minute, start_minute, end_minute) &&
  enough_drones_for_mission(available_drones, workload)
}

///|
/// Decide next state when dispatching.
pub fn next_state_after_dispatch(can_start : Bool) -> Int {
  if can_start {
    schedule_state_running()
  } else {
    schedule_state_waiting()
  }
}

///|
/// Check whether a running task should pause.
pub fn should_pause_task(
  weather_bad : Bool,
  battery_low : Bool,
  obstacle_blocked : Bool,
) -> Bool {
  weather_bad || battery_low || obstacle_blocked
}

///|
/// Check whether a paused task can resume.
pub fn can_resume_task(
  weather_ok : Bool,
  battery_ok : Bool,
  route_clear : Bool,
) -> Bool {
  weather_ok && battery_ok && route_clear
}

///|
/// Estimate total queue pressure.
pub fn queue_pressure(
  waiting_count : Int,
  running_count : Int,
  urgent_count : Int,
) -> Int {
  let safe_waiting = if waiting_count < 0 { 0 } else { waiting_count }
  let safe_running = if running_count < 0 { 0 } else { running_count }
  let safe_urgent = if urgent_count < 0 { 0 } else { urgent_count }
  safe_waiting * 2 + safe_running * 3 + safe_urgent * 5
}

///|
/// Convert queue pressure to readable level.
pub fn queue_pressure_name(pressure : Int) -> String {
  if pressure >= 40 {
    "overloaded"
  } else if pressure >= 20 {
    "busy"
  } else if pressure >= 8 {
    "normal"
  } else {
    "light"
  }
}

///|
/// Suggest scheduler mode.
pub fn scheduler_mode_name(pressure : Int) -> String {
  if pressure >= 40 {
    "emergency-priority"
  } else if pressure >= 20 {
    "priority-balanced"
  } else {
    "energy-saving"
  }
}

///|
/// Check whether rescheduling is recommended.
pub fn should_reschedule(
  pressure : Int,
  failed_task_count : Int,
  emergency_count : Int,
) -> Bool {
  pressure >= 30 || failed_task_count > 0 || emergency_count > 0
}

///|
/// Scheduler module demo.
pub fn scheduler_summary() -> Unit {
  let workload = estimate_mission_workload(50, 5)
  let score = schedule_score(mission_priority_high(), workload, 15, 25)
  let pressure = queue_pressure(4, 2, 1)

  println("Scheduler module:")
  println("- Task states: waiting, ready, running, paused, finished, cancelled")
  println(
    "- Score rule: priority + deadline bonus + waiting penalty - workload cost",
  )
  println("- Dispatch rule: ready task + open time window + enough drones")
  println("- Pause rule: bad weather, low battery, or blocked route")
  println("- Example state:")
  println(schedule_state_name(schedule_state_ready()))
  println("- Example queue pressure:")
  println(queue_pressure_name(pressure))
  println("- Example scheduler mode:")
  println(scheduler_mode_name(pressure))
  println("- Example score level:")
  if score >= 250 {
    println("high")
  } else if score >= 150 {
    println("medium")
  } else {
    println("low")
  }
}
