///|
/// Swarm coordination module for AgriDroneSwarm.

///|
pub fn swarm_clamp_non_negative(value: Int) -> Int {
  if value < 0 {
    0
  } else {
    value
  }
}

///|
pub fn swarm_clamp_percent(value: Int) -> Int {
  if value < 0 {
    0
  } else if value > 100 {
    100
  } else {
    value
  }
}

///|
pub fn swarm_active_ratio_percent(active_drones: Int, total_drones: Int) -> Int {
  let active = swarm_clamp_non_negative(active_drones)
  let total = swarm_clamp_non_negative(total_drones)

  if total <= 0 {
    0
  } else {
    swarm_clamp_percent(active * 100 / total)
  }
}

///|
pub fn swarm_average_load_percent(total_load_percent: Int, drone_count: Int) -> Int {
  let load = swarm_clamp_non_negative(total_load_percent)
  let count = swarm_clamp_non_negative(drone_count)

  if count <= 0 {
    0
  } else {
    swarm_clamp_percent(load / count)
  }
}

///|
pub fn swarm_communication_quality_score(
  connected_drones: Int,
  total_drones: Int,
  packet_loss_percent: Int
) -> Int {
  let connected_ratio = swarm_active_ratio_percent(connected_drones, total_drones)
  let packet_loss = swarm_clamp_percent(packet_loss_percent)

  swarm_clamp_percent(connected_ratio - packet_loss)
}

///|
pub fn swarm_coordination_score(
  active_ratio_percent: Int,
  communication_quality_score: Int,
  average_load_percent: Int
) -> Int {
  let active = swarm_clamp_percent(active_ratio_percent)
  let communication = swarm_clamp_percent(communication_quality_score)
  let load = swarm_clamp_percent(average_load_percent)

  let load_balance_score = 100 - load / 2
  swarm_clamp_percent(active / 3 + communication / 3 + load_balance_score / 3)
}

///|
pub fn swarm_mission_capacity_hectares(
  active_drones: Int,
  hectares_per_drone: Int
) -> Int {
  swarm_clamp_non_negative(active_drones) * swarm_clamp_non_negative(hectares_per_drone)
}

///|
pub fn swarm_required_drones(
  mission_hectares: Int,
  hectares_per_drone: Int
) -> Int {
  let mission = swarm_clamp_non_negative(mission_hectares)
  let capacity = swarm_clamp_non_negative(hectares_per_drone)

  if capacity <= 0 {
    0
  } else {
    (mission + capacity - 1) / capacity
  }
}

///|
pub fn swarm_has_enough_drones(
  active_drones: Int,
  required_drones: Int
) -> Bool {
  swarm_clamp_non_negative(active_drones) >= swarm_clamp_non_negative(required_drones)
}

///|
pub fn swarm_status(
  coordination_score: Int,
  has_enough_drones: Bool
) -> String {
  let score = swarm_clamp_percent(coordination_score)

  if !has_enough_drones {
    "insufficient_drones"
  } else if score >= 80 {
    "excellent"
  } else if score >= 60 {
    "stable"
  } else if score >= 40 {
    "weak"
  } else {
    "unstable"
  }
}

///|
pub fn swarm_should_rebalance(
  average_load_percent: Int,
  communication_quality_score: Int,
  inactive_drones: Int
) -> Bool {
  let load = swarm_clamp_percent(average_load_percent)
  let communication = swarm_clamp_percent(communication_quality_score)
  let inactive = swarm_clamp_non_negative(inactive_drones)

  load >= 75 || communication < 55 || inactive > 0
}

///|
pub fn swarm_summary() -> Unit {
  let total_drones = 12
  let active_drones = 10
  let connected_drones = 9
  let inactive_drones = total_drones - active_drones
  let total_load = 680
  let packet_loss = 6
  let mission_hectares = 180
  let hectares_per_drone = 18

  let active_ratio = swarm_active_ratio_percent(active_drones, total_drones)
  let average_load = swarm_average_load_percent(total_load, active_drones)
  let communication = swarm_communication_quality_score(
    connected_drones,
    total_drones,
    packet_loss
  )
  let coordination = swarm_coordination_score(
    active_ratio,
    communication,
    average_load
  )
  let capacity = swarm_mission_capacity_hectares(active_drones, hectares_per_drone)
  let required = swarm_required_drones(mission_hectares, hectares_per_drone)
  let enough = swarm_has_enough_drones(active_drones, required)
  let status = swarm_status(coordination, enough)
  let rebalance = swarm_should_rebalance(
    average_load,
    communication,
    inactive_drones
  )

  println("Swarm Summary")
  println("active ratio: \{active_ratio}%")
  println("average load: \{average_load}%")
  println("communication quality: \{communication}")
  println("coordination score: \{coordination}")
  println("mission capacity hectares: \{capacity}")
  println("required drones: \{required}")
  println("has enough drones: \{enough}")
  println("status: \{status}")
  println("should rebalance: \{rebalance}")
}
