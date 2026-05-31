// matrix3_test.mbt
test "matrix3_create" {
    let m = Matrix3::identity()
    inspect(m.data[0][0], content="1")
    inspect(m.data[1][1], content="1")
    inspect(m.data[2][2], content="1")
}

test "matrix3_add" {
    let a = Matrix3::new([[1.0,2.0,3.0],[4.0,5.0,6.0],[7.0,8.0,9.0]])
    let b = Matrix3::new([[9.0,8.0,7.0],[6.0,5.0,4.0],[3.0,2.0,1.0]])
    let c = a.add(b)
    inspect(c.data[0][0], content="10")
    inspect(c.data[1][1], content="10")
    inspect(c.data[2][2], content="10")
}

test "matrix3_mul" {
    let a = Matrix3::new([[1.0,0.0,0.0],[0.0,1.0,0.0],[0.0,0.0,1.0]])
    let b = Matrix3::new([[2.0,0.0,0.0],[0.0,2.0,0.0],[0.0,0.0,2.0]])
    let c = a.mul(b)
    inspect(c.data[0][0], content="2")
    inspect(c.data[1][1], content="2")
    inspect(c.data[2][2], content="2")
}

test "matrix3_det" {
    let m = Matrix3::new([[1.0,2.0,3.0],[4.0,5.0,6.0],[7.0,8.0,9.0]])
    inspect(m.det(), content="0")
    let n = Matrix3::identity()
    inspect(n.det(), content="1")
}

test "matrix3_inverse" {
    let m = Matrix3::new([[4.0,7.0,2.0],[3.0,6.0,1.0],[2.0,5.0,3.0]])
    match m.inverse() {
        Some(inv) => {
            let identity = m.mul(inv)
            // 检查对角元接近1，非对角接近0
            inspect(identity.data[0][0] > 0.99, content="true")
            inspect(identity.data[1][1] > 0.99, content="true")
            inspect(identity.data[2][2] > 0.99, content="true")
            inspect(identity.data[0][1].abs() < 1e-6, content="true")
        }
        None => { inspect(false, content="true") }
    }
}