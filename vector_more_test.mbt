test "vector3d_add_sub_dot_more" {
  let a = Vector3D::new(1.0, 2.0, 3.0)
  let b = Vector3D::new(4.0, 5.0, 6.0)

  let c = a.add(b)
  inspect(c.x, content="5")
  inspect(c.y, content="7")
  inspect(c.z, content="9")

  let d = b.sub(a)
  inspect(d.x, content="3")
  inspect(d.y, content="3")
  inspect(d.z, content="3")

  inspect(a.dot(b), content="32")
}

test "vector3d_cross_orthogonal" {
  let x = Vector3D::new(1.0, 0.0, 0.0)
  let y = Vector3D::new(0.0, 1.0, 0.0)
  let z = x.cross(y)

  inspect(z.dot(x), content="0")
  inspect(z.dot(y), content="0")
  inspect(z.z, content="1")
}

test "vector3d_zero_length" {
  let v = Vector3D::new(0.0, 0.0, 0.0)
  inspect(v.length(), content="0")
}
