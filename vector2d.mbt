///|
pub struct Vector2D {
  x : Double
  y : Double
}

///|
pub fn Vector2D::new(x : Double, y : Double) -> Vector2D {
  { x, y }
}

///|
pub fn Vector2D::add(self : Vector2D, other : Vector2D) -> Vector2D {
  { x: self.x + other.x, y: self.y + other.y }
}

///|
pub fn Vector2D::sub(self : Vector2D, other : Vector2D) -> Vector2D {
  { x: self.x - other.x, y: self.y - other.y }
}

///|
pub fn Vector2D::scale(self : Vector2D, k : Double) -> Vector2D {
  { x: self.x * k, y: self.y * k }
}

///|
pub fn Vector2D::dot(self : Vector2D, other : Vector2D) -> Double {
  self.x * other.x + self.y * other.y
}

///|
pub fn Vector2D::length(self : Vector2D) -> Double {
  self.dot(self).sqrt()
}

///|
pub fn Vector2D::normalize(self : Vector2D) -> Vector2D {
  let len = self.length()
  if len == 0.0 {
    Vector2D::new(0.0, 0.0)
  } else {
    self.scale(1.0 / len)
  }
}
