class LostInMaze
  attr_reader :pos

  def initialize(maze)
    @maze = maze
    @solution = maze.solve
    @pos = maze.start
  end

  def up
    move(Maze::UP)
  end

  def down
    move(Maze::DOWN)
  end

  def left
    move(Maze::LEFT)
  end

  def right
    move(Maze::RIGHT)
  end

  def move(delta)
    new_pos = Maze.pos_add(pos, delta)
    @pos = new_pos if @maze[new_pos] != :wall
  end

  def display(show_solution)
    rows, cols = @maze.dimensions
    display_maze = show_solution ? @solution : @maze

    strs = display_maze.to_s.split("\n")
    strs[pos.first][pos.last] = "@"
    strs.join("\n")
  end
end

class Maze
  FILE_TO_SYMBOLS = {
    "*" => :wall,
    " " => :free,
    "S" => :start,
    "E" => :finish,
    "#" => :solution
  }

  UP    = [-1,  0]
  DOWN  = [ 1,  0]
  LEFT  = [ 0, -1]
  RIGHT = [ 0,  1]
  DELTAS = [UP, DOWN, LEFT, RIGHT]

  def self.generate(rows, columns)
    maze_board = Array.new(rows) { [:wall] * columns }
    maze = Maze.new(maze_board)

    maze.construct([1, 1])
    maze
  end

  def construct(pos)
    self[pos] = :free

    neighbors(pos).shuffle.each do |next_pos|
      construct(next_pos) if constructable(pos, next_pos)
    end
  end

  def load_file(filename)
    maze_lines = File.readlines(filename).map(&:chomp)

    @maze_board = maze_lines.collect do |line|
      line.split("").each_with_index.collect do |square|
        FILE_TO_SYMBOLS[square]
      end
    end

    self
  end

  def [](pos)
    @maze_board[pos.first][pos.last]
  end

  def []=(pos, square)
    @maze_board[pos.first][pos.last] = square
  end

  def dimensions
    [@maze_board.count, @maze_board.first.count]
  end

  def self.from_file(filename)
    Maze.new.load_file(filename)
  end

  def self.pos_add(pos, delta)
    [pos.first + delta.first, pos.last + delta.last]
  end

  def initialize(board=nil)
    unless board.nil?
      @maze_board = board.map { |row| row.dup }
    end
  end

  def to_s
    board = @maze_board.map do |line|
      line.map do |square|
        FILE_TO_SYMBOLS.invert[square]
      end.join
    end.join("\n")
  end

  def start
    find_symbol(:start)
  end

  def finish
    find_symbol(:finish)
  end

  def solve
    dup.solve!
  end

  def solve!
    start_pos = start
    passage_queue = [start_pos]
    came_from = {start_pos => nil}

    until passage_queue.empty?
      current_passage = passage_queue.shift

      break if self[current_passage] == :finish

      free_neighbors(current_passage).each do |neighbor|
        unless came_from.keys.include?(neighbor)
          passage_queue << neighbor
          came_from[neighbor] = current_passage
        end
      end
    end

    path = find_path(came_from)
    path.each do |pos|
      unless self[pos] == :start || self[pos] == :finish
        self[pos] = :solution
      end
    end

    self
  end

  def dup
    Maze.new(@maze_board)
  end

  private
  def find_symbol(sym)
    rows, cols = dimensions
    rows.times do |row|
      cols.times do |col|
        return [row, col] if self[[row, col]] == sym
      end
    end

    nil
  end

  def free_neighbors(pos)
    neighbors(pos).reject { |square| self[square] == :wall }
  end

  def neighbors(pos)
    DELTAS.map do |delta|
      new_pos = Maze.pos_add(pos, delta)
    end
  end

  def find_path(came_from)
    finish_pos = finish
    return nil unless came_from.keys.include?(finish_pos)

    current_pos = finish_pos
    [].tap do |path|
      until self[current_pos] == :start
        path << current_pos
        current_pos = came_from[current_pos]
      end
    end
  end

  def edge?(pos)
    pos.include?(0) || pos.first == @maze_board.count - 1 ||
      pos.last == @maze_board[0].count - 1
  end

  def constructable(pos, next_pos)
    !edge?(next_pos) &&
      neighbors(next_pos).one? { |n| self[n] != :wall }
  end
end
