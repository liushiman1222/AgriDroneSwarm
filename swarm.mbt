pub struct Drone {
  id: Int
  position: Vector2D
  velocity: Vector2D
  max_speed: Double
}

pub struct Swarm {
  drones: Array[Drone]
}

pub fn Drone::new(
  id: Int,
  position: Vector2D,
  velocity: Vector2D,
  max_speed: Double
) -> Drone {
  {
    id,
    position,
    velocity,
    max_speed,
  }
}

pub fn Drone::speed(self: Drone) -> Double {
  self.velocity.length()
}

pub fn Drone::with_velocity(self: Drone, velocity: Vector2D) -> Drone {
  {
    id: self.id,
    position: self.position,
    velocity,
    max_speed: self.max_speed,
  }
}

pub fn Drone::with_position(self: Drone, position: Vector2D) -> Drone {
  {
    id: self.id,
    position,
    velocity: self.velocity,
    max_speed: self.max_speed,
  }
}

pub fn Drone::limit_speed(self: Drone) -> Drone {
  let speed = self.speed()
  if speed <= self.max_speed {
    self
  } else {
    let limited_velocity = self.velocity.normalize().scale(self.max_speed)
    self.with_velocity(limited_velocity)
  }
}

pub fn Drone::step(self: Drone, dt: Double) -> Drone {
  let drone = self.limit_speed()
  let delta = drone.velocity.scale(dt)
  drone.with_position(drone.position.add(delta))
}

pub fn Swarm::new(drones: Array[Drone]) -> Swarm {
  { drones: drones }
}

pub fn Swarm::size(self: Swarm) -> Int {
  self.drones.length()
}

pub fn Swarm::is_empty(self: Swarm) -> Bool {
  self.size() == 0
}

pub fn Swarm::step(self: Swarm, dt: Double) -> Swarm {
  let result = Array::new()
  for drone in self.drones {
    result.push(drone.step(dt))
  }
  { drones: result }
}
