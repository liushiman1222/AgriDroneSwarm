// astar.mbt - A* 路径规划

/// 二维坐标点
pub struct Point {
    x: Int
    y: Int
}

pub fn Point::new(x: Int, y: Int) -> Point {
    { x, y }
}

/// 节点用于A*搜索
struct Node {
    point: Point
    parent_idx: Int   // 父节点在列表中的索引，-1表示起点
    g: Int            // 起点到当前点的实际代价
    h: Int            // 启发式代价（曼哈顿距离）
    f: Int            // g + h
}

/// 曼哈顿距离启发函数
fn heuristic(a: Point, b: Point) -> Int {
    (a.x - b.x).abs() + (a.y - b.y).abs()
}

/// 获取邻居点（上下左右），排除边界外
fn get_neighbors(p: Point, width: Int, height: Int) -> Array[Point] {
    let mut neighbors = []
    let dirs = [(-1,0), (1,0), (0,-1), (0,1)]
    for (dx, dy) in dirs {
        let nx = p.x + dx
        let ny = p.y + dy
        if nx >= 0 && nx < width && ny >= 0 && ny < height {
            neighbors.push(Point::new(nx, ny))
        }
    }
    neighbors
}

/// A* 主算法
/// 返回从 start 到 goal 的路径点列表（包含起点和终点），如果不可达则返回 None
pub fn a_star(start: Point, goal: Point, width: Int, height: Int, obstacles: Array[Point]) -> Option[Array[Point]] {
    // 将障碍物转换为Set以便快速查找
    let mut obstacle_set = Set::new()
    for p in obstacles {
        obstacle_set.add(p)
    }

    // 开放集：待探索的点 -> 节点索引
    let mut open_set = Map::new()
    // 关闭集：已探索的点
    let mut closed_set = Set::new()

    // 节点列表
    let mut nodes = []

    // 创建起始节点
    let start_node = Node::new(start, -1, 0, heuristic(start, goal))
    nodes.push(start_node)
    open_set.insert(start, 0)

    while not open_set.is_empty() {
        // 找到 f 值最小的节点
        let mut best_idx = -1
        let mut best_f = 999999
        for (point, idx) in open_set.entries() {
            let f = nodes[idx].f
            if f < best_f {
                best_f = f
                best_idx = idx
            }
        }
        if best_idx == -1 { break }
        let current = nodes[best_idx]
        open_set.remove(current.point)
        closed_set.add(current.point)

        if current.point == goal {
            // 重建路径
            let mut path = []
            let mut cur = current
            loop {
                path.push(cur.point)
                if cur.parent_idx == -1 { break }
                cur = nodes[cur.parent_idx]
            }
            path.reverse()
            return Some(path)
        }

        for neighbor in get_neighbors(current.point, width, height) {
            if closed_set.contains(neighbor) { continue }
            if obstacle_set.contains(neighbor) { continue }

            let tentative_g = current.g + 1
            let existing_idx = open_set.get(neighbor)
            if existing_idx.is_none() || tentative_g < nodes[existing_idx.unwrap()].g {
                let h = heuristic(neighbor, goal)
                let new_node = Node::new(neighbor, best_idx, tentative_g, h)
                let new_idx = nodes.length()
                nodes.push(new_node)
                open_set.insert(neighbor, new_idx)
            }
        }
    }

    None
}

// 辅助函数：为 Node 提供构造函数（因为 Node 不是公开的，但我们内部使用）
fn Node::new(point: Point, parent_idx: Int, g: Int, h: Int) -> Node {
    { point: point, parent_idx: parent_idx, g: g, h: h, f: g + h }
}