// cmd/main/main.mbt

fn main {
    println("=== 寻路 + PID 跟踪 Demo ===\n")

    // 定义网格地图（10x10）
    let width = 10
    let height = 10

    // 起点和终点（网格坐标，整数）
    let start_grid = Point::new(1, 1)
    let goal_grid = Point::new(8, 8)

    // 障碍物（例如一些格子）
    let obstacles = [
        Point::new(4, 4), Point::new(4, 5), Point::new(5, 4), Point::new(5, 5),
        Point::new(2, 7), Point::new(3, 7), Point::new(7, 2), Point::new(7, 3),
    ]

    // 计算路径
    let path_opt = a_star(start_grid, goal_grid, width, height, obstacles)
    match path_opt {
        None => {
            println("无法找到路径！")
            return
        }
        Some(path) => {
            println("找到路径，共 {} 个节点（包括起点和终点）", path.length())
            print("路径点: ")
            for p in path {
                print("({},{}) ", p.x, p.y)
            }
            println("\n")
        }
    }

    // 提取路径点（连续坐标），将整数网格坐标转换为连续坐标（中心点）
    let waypoints = path_opt.unwrap()
    let mut waypoints_cont = []
    for p in waypoints {
        waypoints_cont.push(Vector2D::new(p.x as Double, p.y as Double))
    }

    // 无人机初始位置（从起点开始）
    let mut drone_pos = waypoints_cont[0]
    let mut current_target_idx = 1  // 下一个目标点索引
    let target_tolerance = 0.1       // 到达目标的距离阈值

    // PID 控制器（位置控制，输出速度）
    let mut pid = PID::new(2.0, 0.0, 0.5)  // 比例增益2，微分0.5

    // 模拟参数
    let dt = 0.1
    let max_steps = 500
    let mut step = 0

    println("开始跟踪...\n")

    while current_target_idx < waypoints_cont.length() && step < max_steps {
        let target = waypoints_cont[current_target_idx]

        // 计算位置误差（目标 - 当前位置）
        let error_x = target.x - drone_pos.x
        let error_y = target.y - drone_pos.y
        let distance = (error_x * error_x + error_y * error_y).sqrt()

        // 如果接近当前目标点，切换到下一个
        if distance < target_tolerance {
            println("到达目标点 {}: ({:.2}, {:.2})", current_target_idx, target.x, target.y)
            current_target_idx += 1
            if current_target_idx >= waypoints_cont.length() {
                break
            }
            // 重置 PID 积分项（可选）
            pid.reset()
            continue
        }

        // 简便：使用 P 控制器产生速度（为了 demo，使用比例控制）
        let speed_x = 2.0 * error_x
        let speed_y = 2.0 * error_y

        // 限制最大速度
        let max_speed = 2.0
        let speed = (speed_x * speed_x + speed_y * speed_y).sqrt()
        let (vx, vy) = if speed > max_speed {
            (speed_x / speed * max_speed, speed_y / speed * max_speed)
        } else {
            (speed_x, speed_y)
        }

        // 更新位置
        drone_pos.x += vx * dt
        drone_pos.y += vy * dt

        // 每10步打印一次位置
        if step % 10 == 0 {
            println("步数 {}: 位置 ({:.2}, {:.2}), 目标 ({:.2}, {:.2}), 距离 {:.2}",
                    step, drone_pos.x, drone_pos.y, target.x, target.y, distance)
        }

        step += 1
    }

    if current_target_idx >= waypoints_cont.length() {
        println("\n成功到达终点！最终位置: ({:.2}, {:.2})", drone_pos.x, drone_pos.y)
    } else {
        println("\n超过最大步数，未能到达终点。")
    }
}