// astar_test.mbt
test "a_star_simple" {
    let start = Point::new(0, 0)
    let goal = Point::new(2, 2)
    let width = 3
    let height = 3
    let obstacles = []
    match a_star(start, goal, width, height, obstacles) {
        Some(path) => {
            // 路径长度至少为 4 (0,0)->(0,1)->(1,1)->(2,1)->(2,2) 可能，最短4步曼哈顿距离
            inspect(path.length() >= 4, content="true")
            inspect(path[path.length()-1] == goal, content="true")
        }
        None => inspect(false, content="true")
    }
}

test "a_star_with_obstacle" {
    let start = Point::new(0, 0)
    let goal = Point::new(2, 2)
    let width = 3
    let height = 3
    let obstacles = [Point::new(1,1)]  // 中间堵住
    match a_star(start, goal, width, height, obstacles) {
        Some(path) => {
            // 必须绕路，路径长度应大于曼哈顿距离4
            inspect(path.length() > 4, content="true")
        }
        None => inspect(false, content="true")
    }
}

test "a_star_unreachable" {
    let start = Point::new(0, 0)
    let goal = Point::new(2, 2)
    let width = 3
    let height = 3
    // 所有通路堵死
    let obstacles = [Point::new(1,0), Point::new(0,1), Point::new(1,2), Point::new(2,1)]
    match a_star(start, goal, width, height, obstacles) {
        Some(_) => inspect(false, content="true")
        None => inspect(true, content="true")
    }
}