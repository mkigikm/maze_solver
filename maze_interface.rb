#!/usr/bin/env ruby

require 'dispel'
require './maze_solver'

class MazeConsole
  CONTROLS = "q=Quit s=Toggle solution"
  DEFAULT_FILE = "maze1.txt"

  def initialize(maze)
    @player = LostInMaze.new(maze)
  end

  def draw(show_solution)
    [@player.display(show_solution), CONTROLS].join("\n")
  end

  def run
    show_solution = false

    Dispel::Screen.open do |screen|
      screen.draw(draw(show_solution), [], @player.pos)

      Dispel::Keyboard.output do |key|
        case key
        when "q" then break
        when "s" then show_solution = !show_solution
        when :left then @player.left
        when :right then @player.right
        when :up then @player.up
        when :down then @player.down
        end

        screen.draw(draw(show_solution), [], @player.pos)
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
