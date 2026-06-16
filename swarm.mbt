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
  self.velocity.dot(self.velocity).sqrt()
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

pub fn Drone::step(self: Drone, dt: Double) -> Drone {
  let delta = Vector2D::new(self.velocity.x * dt, self.velocity.y * dt)
  self.with_position(self.position.add(delta))
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
