pub struct Point {
  x: Int
  y: Int
}

pub fn Point::new(x: Int, y: Int) -> Point {
  { x: x, y: y }
}

pub fn demo_path() -> Array[Point] {
  [
    Point::new(0, 0),
    Point::new(1, 0),
    Point::new(2, 0),
    Point::new(3, 0),
    Point::new(3, 1),
    Point::new(3, 2),
  ]
}
