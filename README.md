# Game of Life

A simple implementation of Conway's Game of Life built with Godot 4.3.

## About the Project

Conway's Game of Life is a cellular automaton devised by mathematician John Conway. It simulates how cells on a grid live, die, or multiply based on a set of simple rules:

1. Any live cell with fewer than two live neighbors dies (underpopulation).
2. Any live cell with two or three live neighbors lives on to the next generation.
3. Any live cell with more than three live neighbors dies (overpopulation).
4. Any dead cell with exactly three live neighbors becomes a live cell (reproduction).

This project visualizes these rules in real time and allows users to interact with the simulation.

---

## Features

- **Interactive Grid**: Click to toggle cells between alive and dead.
- **Simulation Controls**: Start, pause, and reset the simulation.
- **Random generation**: Redraw your starting grid with random alive cells.

---


### Prerequisites

- **Godot Engine 4.3**: [Download here](https://godotengine.org/download)


---

## Built With

- **Godot Engine 4.3**: A free and open-source game engine for 2D and 3D games.
- **GDScript**: Godot's built-in scripting language.

---

## License

This project is licensed under the MIT License. See the `LICENSE` file for details.

---

## Acknowledgments

- John Conway for inventing the Game of Life.
- The Godot team for their amazing game engine.

