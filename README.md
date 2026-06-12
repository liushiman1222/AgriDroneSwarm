&#x20;AgriDroneSwarm

面向农田、牧场与渔业场景的无人机集群协同控制、路径规划与区域驱赶算法库。  

A MoonBit-based algorithm library for agricultural drone swarm coordination, path planning, simulation, and region herding.



\## 1. 项目简介

`AgriDroneSwarm` 是一个使用 \*\*MoonBit\*\* 编写的开源算法库，目标是为农牧渔等低空经济应用场景提供一套可复用、可测试、可扩展的无人机集群协同控制基础能力。

项目围绕以下问题展开：

\- 多架无人机如何在农田、牧场、鱼塘等区域内协同执行任务？

\- 如何在存在障碍物的二维网格地图中为无人机规划安全路径？

\- 如何通过 PID 控制器完成目标跟踪、速度调节与轨迹逼近？

\- 如何用几何区域模型描述农田边界、鱼塘范围、牧场围栏与驱赶区域？

\- 如何提供确定性仿真能力，方便算法验证、测试与后续可视化？



当前项目重点实现以下核心模块：

1\. 基础数学模块：二维向量、三阶矩阵、角度工具、常用数学函数；

2\. 几何模块：点、线段、矩形、圆、多边形与区域判断；

3\. 路径规划模块：基于网格地图的 A\* 搜索算法；

4\. 控制模块：带限幅、积分约束和状态重置能力的 PID 控制器；

5\. 无人机模型模块：无人机状态、速度、朝向、电量与任务目标；

6\. 集群协同模块：基础编队、目标分配、区域覆盖和驱赶策略；

7\. 仿真模块：离散时间步进、轨迹记录、场景运行与结果输出；

8\. 示例模块：农田巡检、鱼塘驱离、牧场驱赶等演示场景。



本项目定位不是完整的飞控系统，也不直接控制真实无人机，而是提供一个适合教学、仿真、算法验证和 MoonBit 生态建设的无人机集群算法基础库。



\## 2. 项目背景

在农牧渔业中，无人机已经可以用于：

\- 农田巡检；

\- 作物长势观察；

\- 鸟类驱离；

\- 鱼塘水面巡查；

\- 牧场牲畜辅助驱赶；

\- 围栏、塘埂、作业区边界巡航；

\- 多机协同覆盖大面积区域。



相比单架无人机，多机集群具有更高的覆盖效率和更好的任务容错能力。但是，多机协同时会涉及路径规划、任务分配、区域建模、运动控制、避障和仿真验证等基础问题。

`AgriDroneSwarm` 尝试使用 MoonBit 实现一套轻量级、结构清晰、测试充分的算法库，为 MoonBit 在边缘计算、WebAssembly、仿真和低空经济相关方向上的生态应用提供示例。



\## 3. 项目特性

\### 3.1 计划实现的功能

\- 二维向量 `Vec2`

\- 三阶矩阵 `Matrix3`

\- 角度转换与归一化工具

\- 基础几何计算

\- PID 控制器

\- A\* 路径规划

\- 单元测试结构

\- 网格地图建模

\- 无人机状态模型

\- 多无人机集群模型

\- 任务点分配策略

\- 区域覆盖路径生成

\- 区域驱赶策略

\- 农田巡检示例

\- 鱼塘驱离示例

\- 牧场驱赶示例

\- 仿真轨迹导出

\- GitHub Actions 持续集成

\- API 文档与开发报告



\## 4. 技术栈

\- 编程语言：MoonBit

\- 构建工具：MoonBit 官方工具链

\- 测试工具：`moon test`

\- 版本管理：Git

\- 持续集成：GitHub Actions

\- 项目类型：算法库 / 仿真库 / MoonBit 开源生态项目



\## 5. 目录结构

当前项目结构如下，后续会根据模块规模进一步整理

```text

AgriDroneSwarm/

├── .github/

│   └── workflows/

│       └── ci.yml

├── build/

├── cmd/

├── demo\_main/

├── tests/

├── AgriDroneSwarm.mbt

├── angle.mbt

├── astar.mbt

├── astar\_test.mbt

├── constants.mbt

├── extra\_test.mbt

├── geometry.mbt

├── math\_extra.mbt

├── matrix3.mbt

├── matrix3\_test.mbt

├── pid.mbt

├── pid\_test.mbt

├── utils.mbt

├── vector.mbt

├── vector\_test.mbt

├── moon.mod

├── moon.pkg

├── README.md

├── LICENSE

├── AGENTS.md

├── trace.json

└── .gitignore



