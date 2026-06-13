# AgriDroneSwarm

AgriDroneSwarm 是一个面向农牧渔场景的无人机集群协同控制与驱赶算法库，使用 MoonBit 编写。
项目当前包含基础数学、几何计算、路径规划和控制算法模块，可用于无人机集群控制、路径跟踪、目标驱赶、二维/三维空间计算等场景的算法原型开发。

## 项目目标

本项目希望为农业、牧场、渔场等场景中的无人机集群任务提供一套轻量、清晰、可测试的基础算法库。

典型应用方向包括：
- 农田巡检路径规划
- 牧场牲畜驱赶辅助
- 鱼塘、水域巡查
- 多无人机编队控制
- 任务区域覆盖规划
- 障碍物避让
- 航点跟踪控制
- 基础仿真与算法验证

## 当前状态
当前项目以核心算法库为主，暂不包含复杂可执行入口。
已完成并验证的内容包括：
- 向量计算
- 二维向量计算
- 3x3 矩阵计算
- 角度工具
- 几何工具
- 数学辅助函数
- PID 控制器
- A* 网格路径规划
- 单元测试

当前核心库已通过：
moon check
moon test
moon build
功能模块
向量计算
支持二维和三维向量相关操作，可用于表示无人机位置、速度、方向、目标点等信息。

主要能力包括：
二维向量
三维向量
向量加法
向量减法
标量乘法
点积
叉积
长度计算
距离计算
归一化
矩阵计算
提供 3x3 矩阵基础能力，可用于坐标变换、旋转计算和队形变换。

主要能力包括：
3x3 矩阵定义
单位矩阵
矩阵乘法
矩阵与向量相乘
旋转矩阵
坐标变换
角度工具
用于处理无人机航向角、旋转角和方向角。

主要能力包括：
角度转弧度
弧度转角度
角度归一化
航向角处理
角度差计算
几何工具
用于基础空间判断和几何计算。

主要能力包括：
点与点距离
点与线关系
区域边界判断
包围区域计算
基础空间关系判断
PID 控制
PID 控制器可用于无人机高度、速度、航向角等闭环控制任务。

主要能力包括：
比例控制
积分控制
微分控制
输出限幅
积分项限制
控制器重置
A* 路径规划
A* 模块可用于二维网格环境中的路径搜索。

主要能力包括：
网格路径搜索
起点与终点设置
障碍物避让
启发式代价估计
最短路径生成

项目结构
AgriDroneSwarm/
├── .github/              # GitHub 配置
├── docs/                 # 项目文档
│   └── examples.md       # 使用示例说明
├── tests/                # 测试相关目录
├── AgriDroneSwarm.mbt    # 包入口或聚合文件
├── angle.mbt             # 角度工具
├── astar.mbt             # A* 路径规划
├── astar_test.mbt        # A* 测试
├── astar_more_test.mbt   # A* 扩展测试
├── constants.mbt         # 常量定义
├── extra_test.mbt        # 额外测试
├── geometry.mbt          # 几何工具
├── math_extra.mbt        # 数学扩展
├── matrix3.mbt           # 3x3 矩阵
├── matrix3_test.mbt      # 矩阵测试
├── matrix3_more_test.mbt # 矩阵扩展测试
├── pid.mbt               # PID 控制器
├── pid_test.mbt          # PID 测试
├── pid_more_test.mbt     # PID 扩展测试
├── utils.mbt             # 通用工具
├── vector.mbt            # 三维向量
├── vector_test.mbt       # 三维向量测试
├── vector_more_test.mbt  # 三维向量扩展测试
├── vector2d.mbt          # 二维向量
├── vector2d_test.mbt     # 二维向量测试
├── moon.mod              # MoonBit 模块配置
├── moon.pkg              # MoonBit 包配置
├── LICENSE               # 开源许可证
└── README.md             # 项目说明文档

环境要求
当前已验证版本：
moon 0.1.20260608

安装与检查
克隆项目后进入目录：
git clone https://github.com/liushiman1222/AgriDroneSwarm.git
cd AgriDroneSwarm
检查项目：
moon check
构建项目：
moon test
运行测试：
moon test

开发流程建议
建议在修改代码后按以下顺序检查：
moon check
moon test
moon build
如果全部通过，再提交代码：
git add .
git commit -m "Describe your changes"
示例文档
更多使用思路见：
docs/examples.md
当前示例主要以说明性文档为主，暂不包含复杂可执行入口。这样可以避免入口配置影响核心库的稳定性。

后续计划
后续可以继续扩展以下模块：
swarm.mbt：无人机集群基础模型
formation.mbt：编队控制
herding.mbt：目标驱赶算法
coverage.mbt：区域覆盖规划
obstacle.mbt：障碍物建模与避障
mission.mbt：任务描述与调度
simulation.mbt：轻量级仿真支持
计划增强方向：
增加更多单元测试
增加算法说明文档
增加稳定 examples
增加 GitHub Actions 自动测试
完善农牧渔真实任务场景建模
适用场景
AgriDroneSwarm 可以作为以下项目的算法基础：
农业无人机巡检系统
多无人机协同任务规划
牧场动物驱赶辅助系统
水产养殖巡查系统
无人机路径规划实验
MoonBit 算法库示例项目
许可证
本项目使用 Apache License 2.0。
详情见：LICENSE

