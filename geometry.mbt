///|
pub fn distance(p1 : Vector2D, p2 : Vector2D) -> Double {
  let dx = p1.x - p2.x
  let dy = p1.y - p2.y
  (dx * dx + dy * dy).sqrt()
}

///|
test "distance" {
  let p1 = Vector2D::new(0.0, 0.0)
  let p2 = Vector2D::new(3.0, 4.0)
  inspect(distance(p1, p2), content="5")
}
