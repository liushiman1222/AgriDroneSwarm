fn print_drone_state(id : Int, x : Double, y : Double, altitude : Double) -> Unit {
  println("drone id:")
  println(id)
  println("x:")
  println(x)
  println("y:")
  println(y)
  println("altitude:")
  println(altitude)
  println("----")
}

fn main {
  println("AgriDroneSwarm example: swarm formation")
  println("Formation type: V-shape")
  println("Scenario: agricultural field monitoring")
  println("")

  let leader_x = 100.0
  let leader_y = 100.0
  let altitude = 30.0

  print_drone_state(1, leader_x, leader_y, altitude)
  print_drone_state(2, leader_x - 10.0, leader_y - 10.0, altitude)
  print_drone_state(3, leader_x + 10.0, leader_y - 10.0, altitude)
  print_drone_state(4, leader_x - 20.0, leader_y - 20.0, altitude)
  print_drone_state(5, leader_x + 20.0, leader_y - 20.0, altitude)

  println("Swarm formation initialized successfully.")
}
