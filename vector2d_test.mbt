test "vector2d_add_dot" {
  let a = Vector2D::new(1.0, 2.0)
  let b = Vector2D::new(3.0, 4.0)

  let c = a.add(b)
  inspect(c.x, content="4")
  inspect(c.y, content="6")

  inspect(a.dot(b), content="11")
}

test "vector2d_zero_dot" {
  let a = Vector2D::new(0.0, 0.0)
  let b = Vector2D::new(5.0, -3.0)

  inspect(a.dot(b), content="0")
}
