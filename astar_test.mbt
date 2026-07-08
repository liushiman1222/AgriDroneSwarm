///|
test "a_star_simple" {
  let start = Point::new(0, 0)
  let goal = Point::new(2, 2)
  let obstacles = [Point::new(1, 1)]
  match a_star(start, goal, 5, 5, obstacles) {
    Some(path) => {
      inspect(path.length() > 0, content="true")
      inspect(point_eq(path[path.length() - 1], goal), content="true")
    }
    None => inspect(false, content="true")
  }
}

///|
test "a_star_unreachable" {
  let start = Point::new(0, 0)
  let goal = Point::new(2, 2)
  let obstacles = [Point::new(0, 1), Point::new(1, 0), Point::new(1, 1)]
  match a_star(start, goal, 3, 3, obstacles) {
    Some(_) => inspect(false, content="true")
    None => inspect(true, content="true")
  }
}

///|
test "a_star_with_obstacles" {
  let start = Point::new(0, 0)
  let goal = Point::new(4, 4)
  let obstacles = [Point::new(2, 2), Point::new(2, 3), Point::new(3, 2)]
  match a_star(start, goal, 5, 5, obstacles) {
    Some(path) => {
      // 路径应该存在且不经过障碍物
      let mut has_obstacle = false
      let mut i = 0
      while i < path.length() {
        let p = path[i]
        if contains_point(obstacles, p) {
          has_obstacle = true
        }
        i = i + 1
      }
      inspect(has_obstacle, content="false")
    }
    None => inspect(false, content="true")
  }
}
