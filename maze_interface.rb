#!/usr/bin/env ruby

require 'dispel'
require './maze_solver'

class MazeConsole
  CONTROLS = "q=Quit s=Toggle solution"
  DEFAULT_FILE = "maze1.txt"

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
        when :left
          @maze.player_left
          @maze_solution.player_left
        when :right
          @maze.player_right
          @maze_solution.player_right
        when :up
          @maze.player_up
          @maze_solution.player_up
        when :down
          @maze.player_down
          @maze_solution.player_down
        end
        screen.draw draw(show_solution)
      end
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  maze_file = ARGV.shift
  if maze_file.nil? || !File.file?(maze_file)
    puts "usage: #{$PROGRAM_NAME} <maze_file>"
    exit
  end

  console = MazeConsole.new(Maze.from_file(maze_file))
  console.run
end
