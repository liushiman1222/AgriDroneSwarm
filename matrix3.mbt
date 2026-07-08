///|
pub struct Matrix3 {
  data : Array[Array[Double]]
}

///|
pub fn Matrix3::new(data : Array[Array[Double]]) -> Matrix3 {
  { data, }
}

///|
fn new_matrix3(rows : Array[Array[Double]]) -> Matrix3 {
  if rows.length() != 3 {
    abort("Matrix3 must be 3x3")
  }
  if rows[0].length() != 3 {
    abort("Matrix3 must be 3x3")
  }
  if rows[1].length() != 3 {
    abort("Matrix3 must be 3x3")
  }
  if rows[2].length() != 3 {
    abort("Matrix3 must be 3x3")
  }
  { data: rows }
}

///|
pub fn Matrix3::zero() -> Matrix3 {
  new_matrix3([[0.0, 0.0, 0.0], [0.0, 0.0, 0.0], [0.0, 0.0, 0.0]])
}

///|
pub fn Matrix3::identity() -> Matrix3 {
  new_matrix3([[1.0, 0.0, 0.0], [0.0, 1.0, 0.0], [0.0, 0.0, 1.0]])
}

///|
pub fn Matrix3::add(self : Matrix3, other : Matrix3) -> Matrix3 {
  new_matrix3([
    [
      self.data[0][0] + other.data[0][0],
      self.data[0][1] + other.data[0][1],
      self.data[0][2] + other.data[0][2],
    ],
    [
      self.data[1][0] + other.data[1][0],
      self.data[1][1] + other.data[1][1],
      self.data[1][2] + other.data[1][2],
    ],
    [
      self.data[2][0] + other.data[2][0],
      self.data[2][1] + other.data[2][1],
      self.data[2][2] + other.data[2][2],
    ],
  ])
}

///|
pub fn Matrix3::sub(self : Matrix3, other : Matrix3) -> Matrix3 {
  new_matrix3([
    [
      self.data[0][0] - other.data[0][0],
      self.data[0][1] - other.data[0][1],
      self.data[0][2] - other.data[0][2],
    ],
    [
      self.data[1][0] - other.data[1][0],
      self.data[1][1] - other.data[1][1],
      self.data[1][2] - other.data[1][2],
    ],
    [
      self.data[2][0] - other.data[2][0],
      self.data[2][1] - other.data[2][1],
      self.data[2][2] - other.data[2][2],
    ],
  ])
}

///|
pub fn Matrix3::scalar_mul(self : Matrix3, scalar : Double) -> Matrix3 {
  new_matrix3([
    [
      self.data[0][0] * scalar,
      self.data[0][1] * scalar,
      self.data[0][2] * scalar,
    ],
    [
      self.data[1][0] * scalar,
      self.data[1][1] * scalar,
      self.data[1][2] * scalar,
    ],
    [
      self.data[2][0] * scalar,
      self.data[2][1] * scalar,
      self.data[2][2] * scalar,
    ],
  ])
}

///|
pub fn Matrix3::mul(self : Matrix3, other : Matrix3) -> Matrix3 {
  let a00 = self.data[0][0]
  let a01 = self.data[0][1]
  let a02 = self.data[0][2]
  let a10 = self.data[1][0]
  let a11 = self.data[1][1]
  let a12 = self.data[1][2]
  let a20 = self.data[2][0]
  let a21 = self.data[2][1]
  let a22 = self.data[2][2]

  let b00 = other.data[0][0]
  let b01 = other.data[0][1]
  let b02 = other.data[0][2]
  let b10 = other.data[1][0]
  let b11 = other.data[1][1]
  let b12 = other.data[1][2]
  let b20 = other.data[2][0]
  let b21 = other.data[2][1]
  let b22 = other.data[2][2]

  new_matrix3([
    [
      a00 * b00 + a01 * b10 + a02 * b20,
      a00 * b01 + a01 * b11 + a02 * b21,
      a00 * b02 + a01 * b12 + a02 * b22,
    ],
    [
      a10 * b00 + a11 * b10 + a12 * b20,
      a10 * b01 + a11 * b11 + a12 * b21,
      a10 * b02 + a11 * b12 + a12 * b22,
    ],
    [
      a20 * b00 + a21 * b10 + a22 * b20,
      a20 * b01 + a21 * b11 + a22 * b21,
      a20 * b02 + a21 * b12 + a22 * b22,
    ],
  ])
}

///|
pub fn Matrix3::transpose(self : Matrix3) -> Matrix3 {
  new_matrix3([
    [self.data[0][0], self.data[1][0], self.data[2][0]],
    [self.data[0][1], self.data[1][1], self.data[2][1]],
    [self.data[0][2], self.data[1][2], self.data[2][2]],
  ])
}

///|
pub fn Matrix3::det(self : Matrix3) -> Double {
  let a = self.data[0][0]
  let b = self.data[0][1]
  let c = self.data[0][2]
  let d = self.data[1][0]
  let e = self.data[1][1]
  let f = self.data[1][2]
  let g = self.data[2][0]
  let h = self.data[2][1]
  let i = self.data[2][2]

  a * (e * i - f * h) - b * (d * i - f * g) + c * (d * h - e * g)
}

///|
pub fn Matrix3::adjugate(self : Matrix3) -> Matrix3 {
  let a = self.data[0][0]
  let b = self.data[0][1]
  let c = self.data[0][2]
  let d = self.data[1][0]
  let e = self.data[1][1]
  let f = self.data[1][2]
  let g = self.data[2][0]
  let h = self.data[2][1]
  let i = self.data[2][2]

  new_matrix3([
    [e * i - f * h, -(d * i - f * g), d * h - e * g],
    [-(b * i - c * h), a * i - c * g, -(a * h - b * g)],
    [b * f - c * e, -(a * f - c * d), a * e - b * d],
  ]).transpose()
}

///|
pub fn Matrix3::inverse(self : Matrix3) -> Matrix3? {
  let det = self.det()
  if det == 0.0 {
    None
  } else {
    Some(self.adjugate().scalar_mul(1.0 / det))
  }
}
