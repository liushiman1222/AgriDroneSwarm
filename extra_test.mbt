///|
test "clamp" {
  inspect(clamp(5.0, 0.0, 10.0), content="5")
  inspect(clamp(-1.0, 0.0, 10.0), content="0")
  inspect(clamp(15.0, 0.0, 10.0), content="10")
}

///|
test "lerp" {
  inspect(lerp(0.0, 10.0, 0.5), content="5")
}
