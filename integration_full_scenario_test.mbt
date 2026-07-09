// integration_full_scenario_test.mbt - 完整任务场景集成测试

test "full_scenario_agriculture" {
    // 1. 创建农田区域
    let field = make_demo_field()
    let area = field_area(field)
    inspect(area > 0, content="true")

    // 2. 创建 3 架无人机（模拟 6 架协同）
    let d1 = Drone::new(Vector2D::new(10.0, 10.0), Vector2D::new(1.0, 0.0), 5.0)
    let d2 = Drone::new(Vector2D::new(20.0, 15.0), Vector2D::new(0.0, 1.0), 5.0)
    let d3 = Drone::new(Vector2D::new(15.0, 20.0), Vector2D::new(1.0, 1.0), 5.0)
    let swarm = Swarm::new([d1, d2, d3])

    // 3. 测试集群中心
    let center = swarm.center()
    inspect(center.x > 0.0, content="true")
    inspect(center.y > 0.0, content="true")

    // 4. 测试分散度
    let spread = swarm.average_distance_from_center()
    inspect(spread >= 0.0, content="true")

    // 5. 测试方向一致性
    let alignment = swarm.alignment_score()
    inspect(alignment >= 0.0 && alignment <= 1.0, content="true")

    // 6. 测试任务进度
    let target = Vector2D::new(50.0, 50.0)
    let progress = swarm.mission_progress(target, 10.0)
    inspect(progress >= 0.0 && progress <= 1.0, content="true")

    // 7. 测试队形质量
    let quality = swarm.formation_quality()
    inspect(quality >= 0.0 && quality <= 1.0, content="true")
}

test "pid_control_integration" {
    let mut pid = PID::new(2.0, 0.5, 0.1)
    pid = pid.set_setpoint(10.0)
    let mut measurement = 0.0
    let mut converged = false
    for _ in 0..<50 {
        let control = pid.update(measurement, 0.1)
        measurement += control * 0.05
        if measurement > 9.5 && measurement < 10.5 {
            converged = true
        }
    }
    inspect(converged, content="true")
}