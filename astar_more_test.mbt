test "demo_path_shape" {
  let path = demo_path()

  inspect(path.length(), content="6")
  inspect(path[0].x, content="0")
  inspect(path[0].y, content="0")
  inspect(path[5].x, content="3")
  inspect(path[5].y, content="2")
}
