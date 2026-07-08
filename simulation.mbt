// simulation.mbt - 确定性仿真框架
///|
pub struct DroneState {
  id : Int
  pos_x : Double
  pos_y : Double
  pos_z : Double
  velocity_x : Double
  velocity_y : Double
  velocity_z : Double
  battery : Double
}

///|
pub struct SimEvent {
  time : Double
  drone_id : Int
  event_type : String
  message : String
}

///|
pub struct Simulation {
  time : Double
  drones : Array[DroneState]
  events : Array[SimEvent]
}

///|
pub fn Simulation::new() -> Simulation {
  { time: 0.0, drones: [], events: [] }
}

///|
pub fn Simulation::add_drone(
  self : Simulation,
  drone : DroneState,
) -> Simulation {
  let drones = self.drones
  drones.push(drone)
  { time: self.time, drones, events: self.events }
}

///|
pub fn Simulation::step(self : Simulation, dt : Double) -> Simulation {
  let new_time = self.time + dt
  let new_drones = []
  let mut i = 0
  while i < self.drones.length() {
    let d = self.drones[i]
    let updated = {
      id: d.id,
      pos_x: d.pos_x + d.velocity_x * dt,
      pos_y: d.pos_y + d.velocity_y * dt,
      pos_z: d.pos_z + d.velocity_z * dt,
      velocity_x: d.velocity_x,
      velocity_y: d.velocity_y,
      velocity_z: d.velocity_z,
      battery: d.battery - 0.1 * dt,
    }
    new_drones.push(updated)
    i = i + 1
  }
  { time: new_time, drones: new_drones, events: self.events }
}

///|
pub fn Simulation::log_event(
  self : Simulation,
  drone_id : Int,
  event_type : String,
  message : String,
) -> Simulation {
  let events = self.events
  events.push({ time: self.time, drone_id, event_type, message })
  { time: self.time, drones: self.drones, events }
}

///|
pub fn Simulation::get_drone(self : Simulation, id : Int) -> DroneState? {
  let mut i = 0
  while i < self.drones.length() {
    if self.drones[i].id == id {
      return Some(self.drones[i])
    }
    i = i + 1
  }
  None
}

///|
pub fn Simulation::get_events(self : Simulation) -> Array[SimEvent] {
  self.events
}

///|
pub fn Simulation::get_time(self : Simulation) -> Double {
  self.time
}
