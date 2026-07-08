///|
pub struct Vector3D {
  x : Double
  y : Double
  z : Double
}

///|
pub fn Vector3D::new(x : Double, y : Double, z : Double) -> Vector3D {
  { x, y, z }
}

///|
pub fn Vector3D::add(self : Vector3D, other : Vector3D) -> Vector3D {
  { x: self.x + other.x, y: self.y + other.y, z: self.z + other.z }
}

///|
pub fn Vector3D::sub(self : Vector3D, other : Vector3D) -> Vector3D {
  { x: self.x - other.x, y: self.y - other.y, z: self.z - other.z }
}

///|
pub fn Vector3D::dot(self : Vector3D, other : Vector3D) -> Double {
  self.x * other.x + self.y * other.y + self.z * other.z
}
// 数乘（标量乘法）

///|
pub fn Vector3D::scale(self : Vector3D, scalar : Double) -> Vector3D {
  { x: self.x * scalar, y: self.y * scalar, z: self.z * scalar }
}

// 叉乘

///|
pub fn Vector3D::cross(self : Vector3D, other : Vector3D) -> Vector3D {
  {
    x: self.y * other.z - self.z * other.y,
    y: self.z * other.x - self.x * other.z,
    z: self.x * other.y - self.y * other.x,
  }
}

// 向量长度（模）

///|
pub fn Vector3D::length(self : Vector3D) -> Double {
  (self.x * self.x + self.y * self.y + self.z * self.z).sqrt()
}
