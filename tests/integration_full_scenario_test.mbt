// tests/integration_full_scenario_test.mbt
// 集成测试：完整的智慧农牧渔任务流程
// 覆盖：区域建模 → 无人机状态 → 任务可行性 → 路径规划 → 集群评估

test "full_scenario_agriculture" {
    // 1. 创建任务区域（农田 100x100 米，网格单元 10 米）
    let field = Field::new(100.0, 100.0, 10.0)

    // 2. 创建 3 架无人机（id, 电量%, 初始位置 x, y）
    let drone1 = Drone::new(1, 80.0, 20.0, 20.0)
    let drone2 = Drone::new(2, 90.0, 30.0, 30.0)
    let drone3 = Drone::new(3, 75.0, 25.0, 25.0)
    let fleet = Fleet::new([drone1, drone2, drone3])

    // 3. 定义任务：覆盖区域 (10,10) 到 (90,90)
    let mission = Mission::new("cover", 10.0, 10.0, 90.0, 90.0)

    // 4. 判断任务是否可派发（需实现 mission.is_feasible）
    let can_dispatch = mission.is_feasible(&fleet)
    inspect(can_dispatch, content="true")

    // 5. 路径规划（A*）：起点 (1,1) 到终点 (8,8)，网格 10x10，无障碍
    let start = Point::new(1, 1)
    let goal = Point::new(8, 8)
    let path = a_star(start, goal, 10, 10, [])
    match path {
        Some(p) => {
            // 路径必须包含至少起点和终点
            inspect(p.length() >= 2, content="true")
            // 终点正确
            inspect(p[p.length()-1] == goal, content="true")
        }
        None => inspect(false, content="true")  // 不应该找不到路径
    }

    // 6. 集群状态评估
    let swarm_state = Swarm::evaluate(fleet.drones())
    // 集群中心 x 坐标应大于 0
    inspect(swarm_state.center.x > 0.0, content="true")
    // 集群中心 y 坐标应大于 0
    inspect(swarm_state.center.y > 0.0, content="true")
    // 队形分散度应大于 0（至少两架无人机）
    inspect(swarm_state.dispersion > 0.0, content="true")
}