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
///|
/// A drone in the swarm.
pub struct Drone {
  position : Vector2D
  velocity : Vector2D
  max_speed : Double
}

///|
/// Create a new drone.
pub fn Drone::new(
  position : Vector2D,
  velocity : Vector2D,
  max_speed : Double
) -> Drone {
  Drone::{
    position: position,
    velocity: velocity,
    max_speed: max_speed,
  }
}

///|
/// Limit drone velocity by max_speed while keeping direction unchanged.
pub fn Drone::limit_speed(self : Drone) -> Drone {
  let speed = self.velocity.length()

  if speed > self.max_speed {
    let limited_velocity = self.velocity.normalize().scale(self.max_speed)
    Drone::{
      position: self.position,
      velocity: limited_velocity,
      max_speed: self.max_speed,
    }
  } else {
    self
  }
}

///|
/// Move drone one step using speed-limited velocity.
pub fn Drone::step(self : Drone) -> Drone {
  let drone = self.limit_speed()

  Drone::{
    position: drone.position.add(drone.velocity),
    velocity: drone.velocity,
    max_speed: drone.max_speed,
  }
}
///|
/// A swarm containing multiple drones.
pub struct Swarm {
  drones : Array[Drone]
}

///|
/// Create a new swarm from drones.
pub fn Swarm::new(drones : Array[Drone]) -> Swarm {
  Swarm::{
    drones: drones,
  }
}
///|
/// Move every drone in the swarm one step.
pub fn Swarm::step(self : Swarm) -> Swarm {
  let stepped_drones = self.drones.map(fn(drone) {
    drone.step()
  })

  Swarm::{
    drones: stepped_drones,
  }
}
///|
/// Get number of drones in the swarm.
pub fn Swarm::size(self : Swarm) -> Int {
  self.drones.length()
}
///|
/// Check whether the swarm has no drones.
pub fn Swarm::is_empty(self : Swarm) -> Bool {
  self.drones.length() == 0
}
///|
/// Add a drone to the swarm.
pub fn Swarm::add_drone(self : Swarm, drone : Drone) -> Swarm {
  let drones = self.drones
  drones.push(drone)

  Swarm::{
    drones: drones,
  }
}
///|
/// Calculate average speed of all drones in the swarm.
pub fn Swarm::average_speed(self : Swarm) -> Double {
  if self.drones.length() == 0 {
    0.0
  } else {
    let mut total = 0.0
    let mut count = 0.0

    for drone in self.drones {
      total = total + drone.velocity.length()
      count = count + 1.0
    }

    total / count
  }
}
///|
/// Calculate center position of all drones in the swarm.
pub fn Swarm::center(self : Swarm) -> Vector2D {
  if self.drones.length() == 0 {
    Vector2D::new(0.0, 0.0)
  } else {
    let mut total = Vector2D::new(0.0, 0.0)
    let mut count = 0.0

    for drone in self.drones {
      total = total.add(drone.position)
      count = count + 1.0
    }

    total.scale(1.0 / count)
  }
}
///|
/// Calculate average velocity vector of all drones in the swarm.
pub fn Swarm::average_velocity(self : Swarm) -> Vector2D {
  if self.drones.length() == 0 {
    Vector2D::new(0.0, 0.0)
  } else {
    let mut total = Vector2D::new(0.0, 0.0)
    let mut count = 0.0

    for drone in self.drones {
      total = total.add(drone.velocity)
      count = count + 1.0
    }

    total.scale(1.0 / count)
  }
}

///|
/// Calculate the maximum distance from any drone to the swarm center.
pub fn Swarm::max_distance_from_center(self : Swarm) -> Double {
  if self.drones.length() == 0 {
    0.0
  } else {
    let center = self.center()
    let mut max_distance = 0.0

    for drone in self.drones {
      let offset = drone.position.add(center.scale(-1.0))
      let distance = offset.length()

      if distance > max_distance {
        max_distance = distance
      }
    }

    max_distance
  }
}

///|
/// Calculate the average distance from drones to the swarm center.
pub fn Swarm::average_distance_from_center(self : Swarm) -> Double {
  if self.drones.length() == 0 {
    0.0
  } else {
    let center = self.center()
    let mut total_distance = 0.0
    let mut count = 0.0

    for drone in self.drones {
      let offset = drone.position.add(center.scale(-1.0))
      total_distance = total_distance + offset.length()
      count = count + 1.0
    }

    total_distance / count
  }
}
///|
/// Check whether the swarm is too spread out.
pub fn Swarm::is_too_spread(self : Swarm, max_radius : Double) -> Bool {
  self.max_distance_from_center() > max_radius
}

///|
/// Calculate cohesion score of the swarm.
///
/// The score is in range approximately from 0.0 to 1.0.
/// A higher score means the swarm is more compact.
pub fn Swarm::cohesion_score(self : Swarm) -> Double {
  let spread = self.average_distance_from_center()
  1.0 / (1.0 + spread)
}

///|
/// Calculate alignment score of the swarm.
///
/// The score is in range approximately from 0.0 to 1.0.
/// A higher score means drones are moving in a more consistent direction.
pub fn Swarm::alignment_score(self : Swarm) -> Double {
  if self.drones.length() == 0 {
    1.0
  } else {
    let avg_speed = self.average_speed()

    if avg_speed == 0.0 {
      1.0
    } else {
      let avg_velocity = self.average_velocity()
      let score = avg_velocity.length() / avg_speed

      if score > 1.0 {
        1.0
      } else {
        score
      }
    }
  }
}

///|
/// Check whether the swarm is sufficiently aligned.
pub fn Swarm::is_aligned(self : Swarm, min_score : Double) -> Bool {
  self.alignment_score() >= min_score
}
///|
/// Count drones within a radius from the target position.
pub fn Swarm::count_within_radius(
  self : Swarm,
  target : Vector2D,
  radius : Double
) -> Int {
  let mut count = 0

  for drone in self.drones {
    let offset = drone.position.add(target.scale(-1.0))
    let distance = offset.length()

    if distance <= radius {
      count = count + 1
    }
  }

  count
}

///|
/// Check whether any drone is within a radius from the target position.
pub fn Swarm::any_within_radius(
  self : Swarm,
  target : Vector2D,
  radius : Double
) -> Bool {
  self.count_within_radius(target, radius) > 0
}

///|
/// Check whether all drones are within a radius from the target position.
///
/// Empty swarm returns false because there is no drone to complete the task.
pub fn Swarm::all_within_radius(
  self : Swarm,
  target : Vector2D,
  radius : Double
) -> Bool {
  if self.drones.length() == 0 {
    false
  } else {
    self.count_within_radius(target, radius) == self.drones.length()
  }
}

///|
/// Calculate the nearest distance from any drone to the target position.
///
/// Empty swarm returns 0.0.
pub fn Swarm::nearest_distance_to(
  self : Swarm,
  target : Vector2D
) -> Double {
  if self.drones.length() == 0 {
    0.0
  } else {
    let mut nearest = 0.0
    let mut first = true

    for drone in self.drones {
      let offset = drone.position.add(target.scale(-1.0))
      let distance = offset.length()

      if first {
        nearest = distance
        first = false
      } else if distance < nearest {
        nearest = distance
      }
    }

    nearest
  }
}

///|
/// Calculate the farthest distance from any drone to the target position.
///
/// Empty swarm returns 0.0.
pub fn Swarm::farthest_distance_to(
  self : Swarm,
  target : Vector2D
) -> Double {
  if self.drones.length() == 0 {
    0.0
  } else {
    let mut farthest = 0.0

    for drone in self.drones {
      let offset = drone.position.add(target.scale(-1.0))
      let distance = offset.length()

      if distance > farthest {
        farthest = distance
      }
    }

    farthest
  }
}
///|
/// Calculate the ratio of drones within a radius from the target position.
///
/// Empty swarm returns 0.0.
pub fn Swarm::arrival_ratio(
  self : Swarm,
  target : Vector2D,
  radius : Double
) -> Double {
  if self.drones.length() == 0 {
    0.0
  } else {
    let mut arrived = 0.0
    let mut total = 0.0

    for drone in self.drones {
      let offset = drone.position.add(target.scale(-1.0))
      let distance = offset.length()

      if distance <= radius {
        arrived = arrived + 1.0
      }

      total = total + 1.0
    }

    arrived / total
  }
}

///|
/// Calculate mission progress based on how many drones have arrived near target.
///
/// The result is in range from 0.0 to 1.0.
pub fn Swarm::mission_progress(
  self : Swarm,
  target : Vector2D,
  radius : Double
) -> Double {
  self.arrival_ratio(target, radius)
}

///|
/// Check whether the mission is complete.
///
/// Mission is complete only when all drones are within the target radius.
pub fn Swarm::is_mission_complete(
  self : Swarm,
  target : Vector2D,
  radius : Double
) -> Bool {
  self.all_within_radius(target, radius)
}

///|
/// Calculate coverage radius around the target position.
///
/// This is the farthest distance from any drone to the target.
pub fn Swarm::coverage_radius(
  self : Swarm,
  target : Vector2D
) -> Double {
  self.farthest_distance_to(target)
}

///|
/// Calculate overall formation quality.
///
/// This combines cohesion and alignment.
/// The result is approximately in range from 0.0 to 1.0.
pub fn Swarm::formation_quality(self : Swarm) -> Double {
  let cohesion = self.cohesion_score()
  let alignment = self.alignment_score()

  (cohesion + alignment) * 0.5
}

///|
/// Calculate task readiness score.
///
/// This evaluates whether the swarm is compact and aligned enough for task execution.
pub fn Swarm::task_readiness_score(self : Swarm) -> Double {
  self.formation_quality()
}

///|
/// Check whether the swarm needs regrouping.
///
/// The swarm needs regrouping if it is too spread out or not aligned enough.
pub fn Swarm::needs_regroup(
  self : Swarm,
  max_radius : Double,
  min_alignment : Double
) -> Bool {
  if self.is_too_spread(max_radius) {
    true
  } else {
    self.alignment_score() < min_alignment
  }
}

///|
/// Check whether the swarm is ready for task execution.
///
/// Empty swarm is not ready.
pub fn Swarm::is_ready_for_task(
  self : Swarm,
  max_radius : Double,
  min_alignment : Double
) -> Bool {
  if self.drones.length() == 0 {
    false
  } else if self.is_too_spread(max_radius) {
    false
  } else {
    self.alignment_score() >= min_alignment
  }
}

///|
/// Check whether the swarm is operational.
///
/// A swarm is operational when it has at least one drone.
pub fn Swarm::is_operational(self : Swarm) -> Bool {
  self.drones.length() > 0
}

///|
/// Calculate a general swarm status score.
///
/// This score combines:
/// - whether the swarm has drones
/// - formation cohesion
/// - velocity alignment
///
/// Empty swarm returns 0.0.
pub fn Swarm::status_score(self : Swarm) -> Double {
  if self.drones.length() == 0 {
    0.0
  } else {
    self.formation_quality()
  }
}