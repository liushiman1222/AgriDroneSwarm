///|
/// Helper function for approximate floating point comparison.
fn approx_equal(a : Double, b : Double, eps : Double) -> Bool {
  let diff = a - b
  if diff < 0.0 {
    0.0 - diff <= eps
  } else {
    diff <= eps
  }
}

///|
/// Test empty swarm basic properties.
test "empty swarm basic status" {
  let swarm = Swarm::new([])

  inspect(swarm.size(), content="0")
  inspect(swarm.is_empty(), content="true")
  inspect(swarm.is_operational(), content="false")
  inspect(swarm.status_score(), content="0")
}

///|
/// Test swarm center calculation.
test "swarm center" {
  let d1 = Drone::new(
    Vector2D::new(0.0, 0.0),
    Vector2D::new(0.0, 0.0),
    10.0,
  )
  let d2 = Drone::new(
    Vector2D::new(6.0, 8.0),
    Vector2D::new(0.0, 0.0),
    10.0,
  )

  let swarm = Swarm::new([d1, d2])
  let center = swarm.center()

  inspect(approx_equal(center.x, 3.0, 0.000001), content="true")
  inspect(approx_equal(center.y, 4.0, 0.000001), content="true")
}

///|
/// Test average speed and average velocity.
test "swarm average speed and velocity" {
  let d1 = Drone::new(
    Vector2D::new(0.0, 0.0),
    Vector2D::new(3.0, 4.0),
    10.0,
  )
  let d2 = Drone::new(
    Vector2D::new(10.0, 0.0),
    Vector2D::new(0.0, 0.0),
    10.0,
  )

  let swarm = Swarm::new([d1, d2])

  inspect(approx_equal(swarm.average_speed(), 2.5, 0.000001), content="true")

  let avg_velocity = swarm.average_velocity()
  inspect(approx_equal(avg_velocity.x, 1.5, 0.000001), content="true")
  inspect(approx_equal(avg_velocity.y, 2.0, 0.000001), content="true")
}

///|
/// Test distance from center metrics.
test "swarm distance from center metrics" {
  let d1 = Drone::new(
    Vector2D::new(0.0, 0.0),
    Vector2D::new(0.0, 0.0),
    10.0,
  )
  let d2 = Drone::new(
    Vector2D::new(6.0, 8.0),
    Vector2D::new(0.0, 0.0),
    10.0,
  )

  let swarm = Swarm::new([d1, d2])

  inspect(approx_equal(swarm.max_distance_from_center(), 5.0, 0.000001), content="true")
  inspect(approx_equal(swarm.average_distance_from_center(), 5.0, 0.000001), content="true")
  inspect(swarm.is_too_spread(4.0), content="true")
  inspect(swarm.is_too_spread(6.0), content="false")
}

///|
/// Test target radius checks.
test "swarm target radius checks" {
  let target = Vector2D::new(0.0, 0.0)

  let d1 = Drone::new(
    Vector2D::new(0.0, 0.0),
    Vector2D::new(0.0, 0.0),
    10.0,
  )
  let d2 = Drone::new(
    Vector2D::new(3.0, 4.0),
    Vector2D::new(0.0, 0.0),
    10.0,
  )
  let d3 = Drone::new(
    Vector2D::new(10.0, 0.0),
    Vector2D::new(0.0, 0.0),
    10.0,
  )

  let swarm = Swarm::new([d1, d2, d3])

  inspect(swarm.count_within_radius(target, 5.0), content="2")
  inspect(swarm.any_within_radius(target, 5.0), content="true")
  inspect(swarm.all_within_radius(target, 5.0), content="false")

  inspect(approx_equal(swarm.nearest_distance_to(target), 0.0, 0.000001), content="true")
  inspect(approx_equal(swarm.farthest_distance_to(target), 10.0, 0.000001), content="true")
}

///|
/// Test mission progress and completion.
test "swarm mission progress" {
  let target = Vector2D::new(0.0, 0.0)

  let d1 = Drone::new(
    Vector2D::new(0.0, 0.0),
    Vector2D::new(1.0, 0.0),
    10.0,
  )
  let d2 = Drone::new(
    Vector2D::new(3.0, 4.0),
    Vector2D::new(1.0, 0.0),
    10.0,
  )
  let d3 = Drone::new(
    Vector2D::new(10.0, 0.0),
    Vector2D::new(1.0, 0.0),
    10.0,
  )

  let swarm = Swarm::new([d1, d2, d3])

  inspect(approx_equal(swarm.arrival_ratio(target, 5.0), 0.6666666667, 0.000001), content="true")
  inspect(approx_equal(swarm.mission_progress(target, 5.0), 0.6666666667, 0.000001), content="true")
  inspect(swarm.is_mission_complete(target, 5.0), content="false")
  inspect(swarm.is_mission_complete(target, 10.0), content="true")
  inspect(approx_equal(swarm.coverage_radius(target), 10.0, 0.000001), content="true")
}

///|
/// Test alignment score for aligned swarm.
test "swarm alignment score aligned" {
  let d1 = Drone::new(
    Vector2D::new(0.0, 0.0),
    Vector2D::new(1.0, 0.0),
    10.0,
  )
  let d2 = Drone::new(
    Vector2D::new(1.0, 0.0),
    Vector2D::new(2.0, 0.0),
    10.0,
  )

  let swarm = Swarm::new([d1, d2])

  inspect(approx_equal(swarm.alignment_score(), 1.0, 0.000001), content="true")
  inspect(swarm.is_aligned(0.9), content="true")
}

///|
/// Test alignment score for opposite directions.
test "swarm alignment score opposite directions" {
  let d1 = Drone::new(
    Vector2D::new(0.0, 0.0),
    Vector2D::new(1.0, 0.0),
    10.0,
  )
  let d2 = Drone::new(
    Vector2D::new(1.0, 0.0),
    Vector2D::new(-1.0, 0.0),
    10.0,
  )

  let swarm = Swarm::new([d1, d2])

  inspect(approx_equal(swarm.alignment_score(), 0.0, 0.000001), content="true")
  inspect(swarm.is_aligned(0.5), content="false")
}

///|
/// Test readiness and regroup decision.
test "swarm readiness and regroup" {
  let d1 = Drone::new(
    Vector2D::new(0.0, 0.0),
    Vector2D::new(1.0, 0.0),
    10.0,
  )
  let d2 = Drone::new(
    Vector2D::new(2.0, 0.0),
    Vector2D::new(1.0, 0.0),
    10.0,
  )

  let swarm = Swarm::new([d1, d2])

  inspect(swarm.is_operational(), content="true")
  inspect(swarm.needs_regroup(10.0, 0.8), content="false")
  inspect(swarm.is_ready_for_task(10.0, 0.8), content="true")
  inspect(swarm.task_readiness_score() > 0.0, content="true")
  inspect(swarm.formation_quality() > 0.0, content="true")
  inspect(swarm.status_score() > 0.0, content="true")
}
