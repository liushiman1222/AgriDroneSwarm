// drone_test.mbt - 无人机状态模型测试

test "drone_creation" {
    let pos = Vector2D::new(10.0, 20.0)
    let vel = Vector2D::new(2.0, 3.0)
    let drone = Drone::new(pos, vel, 5.0)
    inspect(drone.position.x, content="10")
    inspect(drone.position.y, content="20")
    inspect(drone.max_speed, content="5")
}

test "drone_speed_limit" {
    let pos = Vector2D::new(0.0, 0.0)
    let vel = Vector2D::new(10.0, 0.0)  // 超过最大速度
    let drone = Drone::new(pos, vel, 5.0)
    let limited = drone.limit_speed()
    // 速度应被限制到最大速度 5.0
    inspect(limited.velocity.x, content="5")
}

test "drone_step" {
    let pos = Vector2D::new(0.0, 0.0)
    let vel = Vector2D::new(2.0, 0.0)
    let drone = Drone::new(pos, vel, 5.0)
    let moved = drone.step()
    inspect(moved.position.x, content="2")
}