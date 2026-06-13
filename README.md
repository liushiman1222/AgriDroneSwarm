# AgriDroneSwarm

AgriDroneSwarm 是一个面向农牧渔场景的无人机集群协同控制与驱赶算法库，使用 MoonBit 编写。

项目当前包含基础数学、几何计算、路径规划和控制算法模块，可用于无人机集群控制、路径跟踪、目标驱赶、二维/三维空间计算等场景的算法原型开发。

## 功能模块

- 向量计算
  - 二维向量
  - 三维向量
  - 距离、归一化、点积、叉积等基础运算

- 矩阵计算
  - 3x3 矩阵
  - 旋转矩阵
  - 矩阵乘法
  - 向量变换

- 角度工具
  - 弧度/角度转换
  - 角度归一化
  - 航向角处理

- 几何工具
  - 点、线、距离计算
  - 包围区域与边界判断
  - 基础空间关系判断

- PID 控制
  - 比例、积分、微分控制
  - 输出限幅
  - 积分项控制

- A* 路径规划
  - 网格路径搜索
  - 障碍物避让
  - 启发式代价估计

## 项目结构

```text
AgriDroneSwarm/
├── angle.mbt          # 角度工具
├── astar.mbt          # A* 路径规划
├── constants.mbt      # 常量定义
├── geometry.mbt       # 几何工具
├── math_extra.mbt     # 数学扩展
├── matrix3.mbt        # 3x3 矩阵
├── pid.mbt            # PID 控制器
├── utils.mbt          # 通用工具
├── vector.mbt         # 三维向量
├── vector2d.mbt       # 二维向量
├── *_test.mbt         # 单元测试
├── moon.mod
└── moon.pkg
