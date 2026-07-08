///|
test "vector2d_add_dot" {
  let a = Vector2D::new(1.0, 2.0)
  let b = Vector2D::new(3.0, 4.0)

  let c = a.add(b)
  inspect(c.x, content="4")
  inspect(c.y, content="6")

  inspect(a.dot(b), content="11")
}

///|
test "vector2d_zero_dot" {
  let a = Vector2D::new(0.0, 0.0)
  let b = Vector2D::new(5.0, -3.0)

  inspect(a.dot(b), content="0")
}

///|
test "vector2d_sub" {
  let a = Vector2D::new(5.0, 7.0)
  let b = Vector2D::new(2.0, 3.0)

  let c = a.sub(b)

  inspect(c.x, content="3")
  inspect(c.y, content="4")
}

///|
test "vector2d_scale" {
  let a = Vector2D::new(2.0, -3.0)

  let b = a.scale(4.0)

  inspect(b.x, content="8")
  inspect(b.y, content="-12")
}

///|
test "vector2d_length" {
  let a = Vector2D::new(3.0, 4.0)

  inspect(a.length(), content="5")
}

///|
test "vector2d_normalize" {
  let a = Vector2D::new(3.0, 4.0)

  let b = a.normalize()

  inspect(b.x, content="0.6000000000000001")
  inspect(b.y, content="0.8")
}

///|
test "vector2d_normalize_zero" {
  let a = Vector2D::new(0.0, 0.0)

  let b = a.normalize()

  inspect(b.x, content="0")
  inspect(b.y, content="0")
}
