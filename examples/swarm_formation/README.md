# Swarm Formation Example

This example demonstrates a simple V-shape formation for an agricultural drone swarm.

## Scenario

A group of 5 drones is initialized for agricultural field monitoring.

The leader drone is placed at the center position, and the other drones are arranged behind it in a V-shape formation.

## Formation

```text
        D1
      /    \
    D2      D3
   /          \
 D4            D5
```

## Files

```text
examples/swarm_formation/
  moon.pkg.json
  main.mbt
  README.md
```

## Run

From the project root:

```bash
moon run examples/swarm_formation
```

## Expected Output

The program prints the position and altitude of each drone in the swarm formation.

## Purpose

This example is intended to demonstrate:

- basic drone initialization
- simple swarm formation
- agricultural monitoring scenario
- executable MoonBit example structure
