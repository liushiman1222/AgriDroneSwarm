// examples/astar_pid_track.mbt
import std
import AgriDroneSwarm

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

fn main() -> Unit {
  let width: Int = 30
  let height: Int = 20

  let start = Point::new(2, 2)
  let goal  = Point::new(27, 17)

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

  let maybe_path = a_star(start, goal, width, height, obstacles)
  match maybe_path {
    None => {
      println("A* failed: no path found.")
    }
    Some(path) => {
      println("A* success. path length (waypoints): " + path.length().to_string())

      let mut pos = Vec2::new(start.x.to_double(), start.y.to_double())

      let dt: Double = 0.1
      let v_max: Double = 2.0
      let wp_tol: Double = 0.35
      let goal_tol: Double = 0.5
      let max_steps: Int = 3000

      let mut wp_idx: Int = 0
      let mut traj_count: Int = 0

      let mut pid = PID::new(1.2, 0.0, 0.2)
      // ✅ 修复：set_setpoint 返回 Unit，不能赋值
      pid.set_setpoint(0.0)

      let print_every: Int = 20
      let mut reached: Bool = false

      for step in 0..max_steps {
        if wp_idx >= path.length() {
          reached = true
          break
        }

        let wp = path[wp_idx]
        let wp_pos = Vec2::new(wp.x.to_double(), wp.y.to_double())

        let e = dist(pos, wp_pos) // 距离误差 >= 0

        // ✅ 修复：PID error = setpoint - measurement
        // setpoint=0 且希望输出 u 与 e 同向为正速度 => measurement 传 -e
        let u = pid.update_error(e, dt)
        let v = clamp(u, 0.0, v_max)

        let dir = normalize(sub(wp_pos, pos))
        pos = add(pos, mul(dir, v * dt))

        if e < wp_tol {
          wp_idx = wp_idx + 1
        }

        traj_count = traj_count + 1

        if step % print_every == 0 {
          let cur_goal_e = dist(pos, Vec2::new(goal.x.to_double(), goal.y.to_double()))
          println(
            "step=" + step.to_string()
            + ", wp_idx=" + wp_idx.to_string()
            + ", e_to_wp=" + e.to_string()
            + ", pos=(" + pos.x.to_string() + "," + pos.y.to_string() + ")"
            + ", e_to_goal=" + cur_goal_e.to_string()
          )
        }

        let e_goal = dist(pos, Vec2::new(goal.x.to_double(), goal.y.to_double()))
        if e_goal < goal_tol {
          reached = true
          break
        }
      }

      let final_e = dist(pos, Vec2::new(goal.x.to_double(), goal.y.to_double()))
      println("Final pos=(" + pos.x.to_string() + "," + pos.y.to_string() + ")")
      println("Final error to goal: " + final_e.to_string())
      println("Result: " + (reached ? "SUCCESS" : "FAIL"))
      println("Trajectory steps: " + traj_count.to_string())
    }
  }
}
