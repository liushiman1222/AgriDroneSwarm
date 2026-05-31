// matrix3.mbt - 3x3 矩阵运算

pub struct Matrix3 {
    data: Array[Array[Double]]  // 3x3 矩阵，按行存储
}

/// 创建新矩阵，从给定的 3x3 数组（每个元素是 Double）
pub fn Matrix3::new(rows: Array[Array[Double]]) -> Matrix3 {
    // 简单检查形状
    if rows.length() != 3 || rows[0].length() != 3 {
        panic("Matrix3 must be 3x3")
    }
    { data: rows }
}

/// 零矩阵
pub fn Matrix3::zero() -> Matrix3 {
    let rows = [
        [0.0, 0.0, 0.0],
        [0.0, 0.0, 0.0],
        [0.0, 0.0, 0.0],
    ]
    Matrix3::new(rows)
}

/// 单位矩阵
pub fn Matrix3::identity() -> Matrix3 {
    let rows = [
        [1.0, 0.0, 0.0],
        [0.0, 1.0, 0.0],
        [0.0, 0.0, 1.0],
    ]
    Matrix3::new(rows)
}

/// 矩阵加法
pub fn Matrix3::add(self: Matrix3, other: Matrix3) -> Matrix3 {
    let mut result_rows = []
    for i in 0..3 {
        let mut row = []
        for j in 0..3 {
            row.push(self.data[i][j] + other.data[i][j])
        }
        result_rows.push(row)
    }
    Matrix3::new(result_rows)
}

/// 矩阵减法
pub fn Matrix3::sub(self: Matrix3, other: Matrix3) -> Matrix3 {
    let mut result_rows = []
    for i in 0..3 {
        let mut row = []
        for j in 0..3 {
            row.push(self.data[i][j] - other.data[i][j])
        }
        result_rows.push(row)
    }
    Matrix3::new(result_rows)
}

/// 数乘
pub fn Matrix3::scalar_mul(self: Matrix3, scalar: Double) -> Matrix3 {
    let mut result_rows = []
    for i in 0..3 {
        let mut row = []
        for j in 0..3 {
            row.push(self.data[i][j] * scalar)
        }
        result_rows.push(row)
    }
    Matrix3::new(result_rows)
}

/// 矩阵乘法
pub fn Matrix3::mul(self: Matrix3, other: Matrix3) -> Matrix3 {
    let mut result_rows = []
    for i in 0..3 {
        let mut row = []
        for j in 0..3 {
            let mut sum = 0.0
            for k in 0..3 {
                sum += self.data[i][k] * other.data[k][j]
            }
            row.push(sum)
        }
        result_rows.push(row)
    }
    Matrix3::new(result_rows)
}

/// 转置
pub fn Matrix3::transpose(self: Matrix3) -> Matrix3 {
    let mut rows = []
    for i in 0..3 {
        let mut row = []
        for j in 0..3 {
            row.push(self.data[j][i])
        }
        rows.push(row)
    }
    Matrix3::new(rows)
}

/// 行列式
pub fn Matrix3::det(self: Matrix3) -> Double {
    let a = self.data[0][0]; let b = self.data[0][1]; let c = self.data[0][2];
    let d = self.data[1][0]; let e = self.data[1][1]; let f = self.data[1][2];
    let g = self.data[2][0]; let h = self.data[2][1]; let i_val = self.data[2][2];
    a * (e * i_val - f * h) - b * (d * i_val - f * g) + c * (d * h - e * g)
}

/// 伴随矩阵（余子式矩阵的转置）
fn Matrix3::adjugate(self: Matrix3) -> Matrix3 {
    let a = self.data[0][0]; let b = self.data[0][1]; let c = self.data[0][2];
    let d = self.data[1][0]; let e = self.data[1][1]; let f = self.data[1][2];
    let g = self.data[2][0]; let h = self.data[2][1]; let i_val = self.data[2][2];

    // 余子式矩阵
    let cofactor_rows = [
        [e*i_val - f*h, -(d*i_val - f*g), d*h - e*g],
        [-(b*i_val - c*h), a*i_val - c*g, -(a*h - b*g)],
        [b*f - c*e, -(a*f - c*d), a*e - b*d],
    ];
    // 转置得到伴随矩阵
    let mut adj_rows = []
    for i in 0..3 {
        let mut row = []
        for j in 0..3 {
            row.push(cofactor_rows[j][i])
        }
        adj_rows.push(row)
    }
    Matrix3::new(adj_rows)
}

/// 逆矩阵（要求行列式非零）
pub fn Matrix3::inverse(self: Matrix3) -> Option[Matrix3] {
    let det = self.det()
    if det == 0.0 {
        return None
    }
    let adj = self.adjugate()
    Some(adj.scalar_mul(1.0 / det))
}