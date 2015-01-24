class Maze
  FILE_TO_SYMBOLS = {
    "*" => :wall,
    " " => :free,
    "S" => :start,
    "E" => :finish
  }

  def load_file(filename)
    maze_lines = File.readlines(filename).map(&:chomp)

    @maze_board = maze_lines.collect do |line|
      line.split("").each_with_index.collect do |square|
        FILE_TO_SYMBOLS[square]
      end
    end
  end

  def [](pos)
    @maze_board[pos.first][pos.last]
  end

  def dimensions
    [@maze_board.count, @maze_board.first.count]
  end

  def initialize(filename)
    load_file(filename)
  end

  def to_s
    @maze_board.map do |line|
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

  private
  def find_symbol(sym)
    rows, cols = dimensions
    rows.times do |row|
      cols.times do |col|
        return [row, col] if maze[[row, col]] == sym
      end
    end

    nil
  end

end
