test "vector addition" {
    let v1 = Vector3D::new(1.0, 2.0, 3.0)
    let v2 = Vector3D::new(4.0, 5.0, 6.0)
    let v3 = v1.add(v2)
    inspect(v3.x, content="5")
    inspect(v3.y, content="7")
    inspect(v3.z, content="9")
}

test "vector dot" {
    let v1 = Vector3D::new(1.0, 2.0, 3.0)
    let v2 = Vector3D::new(4.0, 5.0, 6.0)
    let dot_val = v1.dot(v2)
    inspect(dot_val, content="32")
}