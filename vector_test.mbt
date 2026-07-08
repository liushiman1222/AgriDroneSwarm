///|
test "vector scale" {
  let v = Vector3D::new(2.0, 3.0, 4.0)
  let scaled = v.scale(2.0)
  inspect(scaled.x, content="4")
  inspect(scaled.y, content="6")
  inspect(scaled.z, content="8")
}

///|
test "vector cross" {
  let v1 = Vector3D::new(1.0, 0.0, 0.0)
  let v2 = Vector3D::new(0.0, 1.0, 0.0)
  let cross = v1.cross(v2)
  inspect(cross.x, content="0")
  inspect(cross.y, content="0")
  inspect(cross.z, content="1")
}

///|
test "vector length" {
  let v = Vector3D::new(3.0, 4.0, 0.0)
  let len = v.length()
  inspect(len, content="5")
}
