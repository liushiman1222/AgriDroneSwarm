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

test "drone_limit_speed_no_change" {
  let drone = Drone::new(
    1,
    Vector2D::new(0.0, 0.0),
    Vector2D::new(3.0, 4.0),
    10.0,
  )

  let limited = drone.limit_speed()

  inspect(limited.velocity.x, content="3")
  inspect(limited.velocity.y, content="4")
  inspect(limited.speed(), content="5")
}

test "drone_limit_speed_clip" {
  let drone = Drone::new(
    1,
    Vector2D::new(0.0, 0.0),
    Vector2D::new(10.0, 0.0),
    3.0,
  )

  let limited = drone.limit_speed()

  inspect(limited.velocity.x, content="3")
  inspect(limited.velocity.y, content="0")
  inspect(limited.speed(), content="3")
}

test "drone_step_with_speed_limit" {
  let drone = Drone::new(
    1,
    Vector2D::new(0.0, 0.0),
    Vector2D::new(10.0, 0.0),
    3.0,
  )

  let next = drone.step(2.0)

  inspect(next.position.x, content="6")
  inspect(next.position.y, content="0")
  inspect(next.velocity.x, content="3")
  inspect(next.velocity.y, content="0")
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

test "swarm_step_with_speed_limit" {
  let d1 = Drone::new(
    1,
    Vector2D::new(0.0, 0.0),
    Vector2D::new(10.0, 0.0),
    3.0,
  )

  let d2 = Drone::new(
    2,
    Vector2D::new(0.0, 0.0),
    Vector2D::new(0.0, 8.0),
    2.0,
  )

  let swarm = Swarm::new([d1, d2])
  let next = swarm.step(2.0)

  inspect(next.drones[0].position.x, content="6")
  inspect(next.drones[0].position.y, content="0")
  inspect(next.drones[1].position.x, content="0")
  inspect(next.drones[1].position.y, content="4")
}
