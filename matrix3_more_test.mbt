test "matrix3_zero" {
  let z = Matrix3::zero()
  inspect(z.data[0][0], content="0")
  inspect(z.data[1][1], content="0")
  inspect(z.data[2][2], content="0")
}

test "matrix3_sub" {
  let a = Matrix3::new([[5.0,5.0,5.0],[5.0,5.0,5.0],[5.0,5.0,5.0]])
  let b = Matrix3::new([[1.0,2.0,3.0],[4.0,5.0,6.0],[7.0,8.0,9.0]])
  let c = a.sub(b)

  inspect(c.data[0][0], content="4")
  inspect(c.data[1][1], content="0")
  inspect(c.data[2][2], content="-4")
}

test "matrix3_scalar_mul" {
  let a = Matrix3::identity()
  let b = a.scalar_mul(3.0)

  inspect(b.data[0][0], content="3")
  inspect(b.data[1][1], content="3")
  inspect(b.data[2][2], content="3")
}

test "matrix3_transpose" {
  let a = Matrix3::new([[1.0,2.0,3.0],[4.0,5.0,6.0],[7.0,8.0,9.0]])
  let t = a.transpose()

  inspect(t.data[0][1], content="4")
  inspect(t.data[1][0], content="2")
  inspect(t.data[2][1], content="6")
}

test "matrix3_singular_inverse_none" {
  let m = Matrix3::new([[1.0,2.0,3.0],[4.0,5.0,6.0],[7.0,8.0,9.0]])
  match m.inverse() {
    Some(_) => inspect(false, content="true")
    None => inspect(true, content="true")
  }
}
