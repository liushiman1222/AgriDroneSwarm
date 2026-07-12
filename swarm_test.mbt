// swarm_test.mbt - 集群协同评估测试

///|
test "swarm_center" {
  let d1 = Drone::new(Vector2D::new(0.0, 0.0), Vector2D::new(1.0, 0.0), 5.0)
  let d2 = Drone::new(Vector2D::new(10.0, 0.0), Vector2D::new(0.0, 1.0), 5.0)
  let d3 = Drone::new(Vector2D::new(0.0, 10.0), Vector2D::new(1.0, 1.0), 5.0)
  let swarm = Swarm::new([d1, d2, d3])
  let center = swarm.center()
  // 使用范围比较避免浮点数精度问题
  inspect(center.x > 3.33 && center.x < 3.34, content="true")
  inspect(center.y > 3.33 && center.y < 3.34, content="true")
}

///|
test "swarm_cohesion" {
  let d1 = Drone::new(Vector2D::new(0.0, 0.0), Vector2D::new(1.0, 0.0), 5.0)
  let d2 = Drone::new(Vector2D::new(1.0, 1.0), Vector2D::new(0.0, 1.0), 5.0)
  let swarm = Swarm::new([d1, d2])
  let cohesion = swarm.cohesion_score()
  inspect(cohesion > 0.0 && cohesion <= 1.0, content="true")
}

///|
test "swarm_mission_progress" {
  let d1 = Drone::new(Vector2D::new(5.0, 5.0), Vector2D::new(1.0, 0.0), 5.0)
  let d2 = Drone::new(Vector2D::new(6.0, 5.0), Vector2D::new(0.0, 1.0), 5.0)
  let swarm = Swarm::new([d1, d2])
  let target = Vector2D::new(5.0, 5.0)
  let progress = swarm.mission_progress(target, 2.0)
  inspect(progress >= 0.0 && progress <= 1.0, content="true")
}
 
