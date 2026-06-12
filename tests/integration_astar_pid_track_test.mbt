import std

struct Vec2 {
  x: Double
  y: Double
}

fn Vec2::new(x: Double, y: Double) -> Vec2 { { x, y } }

fn sub(a: Vec2, b: Vec2) -> Vec2 { Vec2::new(a.x - b.x, a.y - b.y) }
fn add(a: Vec2, b: Vec2) -> Vec2 { Vec2::new(a.x + b.x, a.y + b.y) }
fn mul(a: Vec2, s: Double) -> Vec2 { Vec2::new(a.x * s, a.y * s) }

fn norm(a: Vec2) -> Double {
  (a.x * a.x + a.y * a.y).sqrt()
}

fn clamp(v: Double, lo: Double, hi: Double) -> Double {
  if v < lo { lo } else if v > hi { hi } else { v }
}

fn normalize(v: Vec2) -> Vec2 {
  let n = norm(v)
  if n <= 1e-9 { Vec2::new(0.0, 0.0) } else { Vec2::new(v.x / n, v.y / n) }
}

fn dist(a: Vec2, b: Vec2) -> Double {
  norm(sub(a, b))
}

fn assert_true(cond: Bool, msg: String) -> Unit {
  if not cond {
    abort(msg)
  }
}

test "integration_astar_pid_track" {
  let width: Int = 30
  let height: Int = 20

  let start = Point::new(2, 2)
  let goal = Point::new(27, 17)

  let obstacles: Array[Point] = [
    Point::new(6, 5), Point::new(7, 5), Point::new(8, 5), Point::new(9, 5),
    Point::new(10, 5), Point::new(11, 5),
    Point::new(6, 6), Point::new(7, 6), Point::new(8, 6), Point::new(9, 6),
    Point::new(10, 6), Point::new(11, 6),

    Point::new(15, 8), Point::new(15, 9), Point::new(15, 10), Point::new(15, 11),
    Point::new(16, 8), Point::new(16, 9), Point::new(16, 10), Point::new(16, 11),

    Point::new(20, 3), Point::new(21, 3), Point::new(22, 3),
    Point::new(20, 4), Point::new(21, 4), Point::new(22, 4)
  ]

  let maybe_path = a_star(start, goal, width, height, obstacles
