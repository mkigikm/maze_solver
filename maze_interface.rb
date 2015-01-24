#!/usr/bin/env ruby

require 'dispel'
require './maze_solver'

class MazeConsole
  CONTROLS = "q=Quit s=Toggle solution"

  def initialize(maze)
    @maze = maze
    @maze_solution = maze.solve
  end

  def draw(show_solution)
    maze = show_solution ? @maze_solution : @maze
    [maze.to_s, CONTROLS].join("\n")
  end

  def run
    positition = @maze.start
    show_solution = false

    Dispel::Screen.open do |screen|
      screen.draw draw(show_solution)

      Dispel::Keyboard.output do |key|
        case key
        when "q" then break
        when "s" then show_solution = !show_solution
        end
        screen.draw draw(show_solution)
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  console = MazeConsole.new(Maze.from_file("maze1.txt"))
  console.run
end
