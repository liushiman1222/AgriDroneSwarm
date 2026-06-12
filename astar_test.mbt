test "demo_path" {
  let path = demo_path()
  inspect(path.length() > 0, content="true")
}
