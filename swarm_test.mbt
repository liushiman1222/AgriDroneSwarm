test "drone_speed" {
  let drone = Drone::new(
    1,
    Vector2D::new(0.0, 0.0),
    Vector2D::new(3.0, 4.0),
    10.0,
  )

  inspect(drone.speed(), content="5")
}

test "drone_step" {
  let drone = Drone::new(
    1,
    Vector2D::new(1.0, 2.0),
    Vector2D::new(3.0, 4.0),
    10.0,
  )

  let next = drone.step(2.0)

  inspect(next.position.x, content="7")
  inspect(next.position.y, content="10")
}

test "swarm_size_empty" {
  let swarm = Swarm::new([])

  inspect(swarm.size(), content="0")
  inspect(swarm.is_empty(), content="true")
}

test "swarm_step" {
  let d1 = Drone::new(
    1,
    Vector2D::new(0.0, 0.0),
    Vector2D::new(1.0, 0.0),
    10.0,
  )

  let d2 = Drone::new(
    2,
    Vector2D::new(0.0, 0.0),
    Vector2D::new(0.0, 2.0),
    10.0,
  )

  let swarm = Swarm::new([d1, d2])
  let next = swarm.step(3.0)

  inspect(next.size(), content="2")
  inspect(next.drones[0].position.x, content="3")
  inspect(next.drones[0].position.y, content="0")
  inspect(next.drones[1].position.x, content="0")
  inspect(next.drones[1].position.y, content="6")
}
