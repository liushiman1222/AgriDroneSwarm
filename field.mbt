///|
pub struct FieldPoint {
  x : Int
  y : Int
}

///|
pub struct FieldSize {
  width : Int
  height : Int
}

///|
pub struct FieldZone {
  id : Int
  name : String
  min_x : Int
  min_y : Int
  max_x : Int
  max_y : Int
}

///|
pub struct FieldObstacle {
  id : Int
  pos : FieldPoint
  radius : Int
}

///|
pub struct FieldBase {
  id : Int
  pos : FieldPoint
  name : String
}

///|
pub struct FarmField {
  size : FieldSize
  crop_zones : Array[FieldZone]
  obstacles : Array[FieldObstacle]
  bases : Array[FieldBase]
}

///|
pub fn make_field_point(x : Int, y : Int) -> FieldPoint {
  { x, y }
}

///|
pub fn make_field_size(width : Int, height : Int) -> FieldSize {
  { width, height }
}

///|
pub fn make_field_zone(
  id : Int,
  name : String,
  min_x : Int,
  min_y : Int,
  max_x : Int,
  max_y : Int,
) -> FieldZone {
  { id, name, min_x, min_y, max_x, max_y }
}

///|
pub fn make_field_obstacle(
  id : Int,
  x : Int,
  y : Int,
  radius : Int,
) -> FieldObstacle {
  { id, pos: make_field_point(x, y), radius }
}

///|
pub fn make_field_base(id : Int, x : Int, y : Int, name : String) -> FieldBase {
  { id, pos: make_field_point(x, y), name }
}

///|
pub fn make_demo_field() -> FarmField {
  {
    size: make_field_size(120, 80),
    crop_zones: [
      make_field_zone(1, "wheat-north", 0, 0, 55, 35),
      make_field_zone(2, "corn-east", 60, 5, 115, 40),
      make_field_zone(3, "soy-south", 10, 45, 100, 75),
    ],
    obstacles: [
      make_field_obstacle(1, 30, 20, 4),
      make_field_obstacle(2, 70, 30, 5),
      make_field_obstacle(3, 90, 60, 3),
    ],
    bases: [
      make_field_base(1, 5, 5, "base-alpha"),
      make_field_base(2, 110, 70, "base-beta"),
    ],
  }
}

///|
pub fn field_area(field : FarmField) -> Int {
  field.size.width * field.size.height
}

///|
pub fn zone_area(zone : FieldZone) -> Int {
  let w = zone.max_x - zone.min_x
  let h = zone.max_y - zone.min_y
  if w <= 0 || h <= 0 {
    0
  } else {
    w * h
  }
}

///|
pub fn total_crop_area(field : FarmField) -> Int {
  let mut total = 0
  for zone in field.crop_zones {
    total = total + zone_area(zone)
  }
  total
}

///|
pub fn in_bounds(field : FarmField, p : FieldPoint) -> Bool {
  p.x >= 0 && p.y >= 0 && p.x < field.size.width && p.y < field.size.height
}

///|
pub fn point_in_zone(p : FieldPoint, zone : FieldZone) -> Bool {
  p.x >= zone.min_x &&
  p.x <= zone.max_x &&
  p.y >= zone.min_y &&
  p.y <= zone.max_y
}

///|
pub fn distance2(a : FieldPoint, b : FieldPoint) -> Int {
  let dx = a.x - b.x
  let dy = a.y - b.y
  dx * dx + dy * dy
}

///|
pub fn blocked_by_obstacle(p : FieldPoint, obs : FieldObstacle) -> Bool {
  distance2(p, obs.pos) <= obs.radius * obs.radius
}

///|
pub fn is_blocked(field : FarmField, p : FieldPoint) -> Bool {
  if !in_bounds(field, p) {
    true
  } else {
    let mut blocked = false
    for obs in field.obstacles {
      if blocked_by_obstacle(p, obs) {
        blocked = true
      }
    }
    blocked
  }
}

///|
pub fn nearest_base_index(field : FarmField, p : FieldPoint) -> Int {
  let mut best = 0
  let mut best_dist = 2147483647
  let mut i = 0
  for base in field.bases {
    let d = distance2(p, base.pos)
    if d < best_dist {
      best = i
      best_dist = d
    }
    i = i + 1
  }
  best
}

///|
pub fn count_zones_covering(field : FarmField, p : FieldPoint) -> Int {
  let mut count = 0
  for zone in field.crop_zones {
    if point_in_zone(p, zone) {
      count = count + 1
    }
  }
  count
}

///|
pub fn field_summary() -> Unit {
  let field = make_demo_field()
  println("Field module:")
  println("  area = " + field_area(field).to_string())
  println("  crop area = " + total_crop_area(field).to_string())
  println("  crop zones = " + field.crop_zones.length().to_string())
  println("  obstacles = " + field.obstacles.length().to_string())
  println("  bases = " + field.bases.length().to_string())
}
