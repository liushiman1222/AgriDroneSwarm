// astar.mbt - A* 路径规划
///|
pub struct Point {
  x : Int
  y : Int
}

///|
pub fn Point::new(x : Int, y : Int) -> Point {
  { x, y }
}

///|
pub fn point_eq(a : Point, b : Point) -> Bool {
  a.x == b.x && a.y == b.y
}

///|
fn heuristic(a : Point, b : Point) -> Int {
  (a.x - b.x).abs() + (a.y - b.y).abs()
}

///|
fn get_neighbors(p : Point, width : Int, height : Int) -> Array[Point] {
  let neighbors = []
  let dxs = [-1, 1, 0, 0]
  let dys = [0, 0, -1, 1]
  let mut i = 0
  while i < 4 {
    let nx = p.x + dxs[i]
    let ny = p.y + dys[i]
    if nx >= 0 && nx < width && ny >= 0 && ny < height {
      neighbors.push(Point::new(nx, ny))
    }
    i = i + 1
  }
  neighbors
}

///|
pub fn contains_point(arr : Array[Point], p : Point) -> Bool {
  let mut i = 0
  while i < arr.length() {
    if point_eq(arr[i], p) {
      return true
    }
    i = i + 1
  }
  false
}

///|
fn find_point(arr : Array[Point], p : Point) -> Int {
  let mut i = 0
  while i < arr.length() {
    if point_eq(arr[i], p) {
      return i
    }
    i = i + 1
  }
  -1
}

///|
pub fn a_star(
  start : Point,
  goal : Point,
  width : Int,
  height : Int,
  obstacles : Array[Point],
) -> Array[Point]? {
  if contains_point(obstacles, start) || contains_point(obstacles, goal) {
    return None
  }

  let mut open_set = [start]
  let closed_set = []
  let came_from = []
  let g_score = [0]
  let f_score = [heuristic(start, goal)]

  while open_set.length() > 0 {
    // 找最小 f 的节点
    let mut current_idx = 0
    let mut current_f = f_score[0]
    let mut i = 1
    while i < open_set.length() {
      if f_score[i] < current_f {
        current_f = f_score[i]
        current_idx = i
      }
      i = i + 1
    }

    let current = open_set[current_idx]
    if point_eq(current, goal) {
      // 重建路径
      let path = [goal]
      let mut cur = current
      let mut found = true
      while found {
        let idx = find_point(came_from, cur)
        if idx == -1 {
          found = false
        } else {
          cur = came_from[idx]
          path.push(cur)
        }
      }
      // 反转路径
      let reversed = []
      let mut j = path.length() - 1
      while j >= 0 {
        reversed.push(path[j])
        j = j - 1
      }
      return Some(reversed)
    }

    // 从 open_set 移除 current
    let new_open = []
    let mut idx = 0
    while idx < open_set.length() {
      if !point_eq(open_set[idx], current) {
        new_open.push(open_set[idx])
      }
      idx = idx + 1
    }
    open_set = new_open
    closed_set.push(current)

    let neighbors = get_neighbors(current, width, height)
    let mut ni = 0
    while ni < neighbors.length() {
      let neighbor = neighbors[ni]
      if contains_point(closed_set, neighbor) {
        ni = ni + 1
        continue
      }
      if contains_point(obstacles, neighbor) {
        ni = ni + 1
        continue
      }

      let tentative_g = g_score[current_idx] + 1
      let neighbor_idx = find_point(open_set, neighbor)
      if neighbor_idx == -1 {
        open_set.push(neighbor)
        came_from.push(current)
        g_score.push(tentative_g)
        f_score.push(tentative_g + heuristic(neighbor, goal))
      } else if tentative_g < g_score[neighbor_idx] {
        came_from[neighbor_idx] = current
        g_score[neighbor_idx] = tentative_g
        f_score[neighbor_idx] = tentative_g + heuristic(neighbor, goal)
      }
      ni = ni + 1
    }
  }

  None
}
