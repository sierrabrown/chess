
class Piece
  attr_accessor :color, :symbol, :location, :board
  
  DIAGONAL_DIRS = [[1,1], [1, -1],[-1, 1],[-1, -1]]
  ORTHOGONAL_DIRS = [[0,1], [0, -1], [1, 0], [-1, 0]]
  
  def initialize(location, color, board)
    @location = location
    @color = color
    @board = board
  end
  
  def on_board?(location)
    #debugger
    (0..7).include?(location[0]) && (0..7).include?(location[1])
  end
  
  def move_into_check?(end_pos)
    new_board = @board.deep_dup 
    new_board.move!(@location, end_pos)
    new_board.in_check?(@color)
  end
    
  def valid_moves
    possible_moves = legal_moves
    possible_moves.select { |pos| !self.move_into_check?(pos) }
  end
  
  def checkmate?
    my_pieces = @board.get_all_pieces(@color)
    escape_moves = my_pieces.inject(0) {|sum, x| sum += valid_moves.count }
    return @board.in_check?(@color) && escape_moves == 0
  end
  
end


class SlidingPiece < Piece
    
    
  def legal_moves 
    array = move_dirs
    legal_moves_arr = []
    array.each do |direction|
      new_loc = @location
        (1..7).each do |steps|
          new_x = (steps * direction[0]) + @location[0]
          new_y = (steps * direction[1]) + @location[1]
          new_loc = [new_x,new_y]
          break if !on_board?(new_loc) || @board.occupied_my_color?(new_loc, self)
          legal_moves_arr << new_loc if on_board?(new_loc)
          break if !on_board?(new_loc) || @board.occupied?(new_loc) 
        end
    end 
    legal_moves_arr
  end
end



class SteppingPiece < Piece
  KNIGHT_MOVES = [[2, 1], [2, -1], [-2, 1], [-2, -1], [1, 2], [1, -2], [-1, 2], [-1, -2]]
  KING_MOVES = DIAGONAL_DIRS + ORTHOGONAL_DIRS
  
  def legal_moves
    array = move_dirs
    legal_moves_arr = []
    array.each do |direction|
      new_loc = @location
      new_x =  direction[0] + @location[0]
      new_y = direction[1] + @location[1]
      new_loc = [new_x,new_y]
      next if !on_board?(new_loc) || @board.occupied_my_color?(new_loc, self)
      legal_moves_arr << new_loc
    end 
    legal_moves_arr
  end
end

class Bishop < SlidingPiece
  
  def initialize(location, color, board)
    @symbol = { "black" => "\u2657", "white" => "\u265d" }
    super
  end
  
  def move_dirs
    DIAGONAL_DIRS
  end
end

class Rook < SlidingPiece
  
  def initialize(location, color, board)
    @symbol = { "black" => "\u2656", "white" => "\u265c" }
    super
  end
  
  def move_dirs
    ORTHOGONAL_DIRS
  end
end

class Queen < SlidingPiece
  
  def initialize(location, color, board)
    @symbol = { "black" => "\u2655", "white" => "\u265b" }
    super
  end
  
  def move_dirs
     DIAGONAL_DIRS + ORTHOGONAL_DIRS
  end
end

class Knight < SteppingPiece 
  
  def initialize(location, color, board)
    @symbol = { "black" => "\u2658", "white" => "\u265e" }
    super
  end
  
  def move_dirs
    KNIGHT_MOVES
  end 
  
  
end

class King < SteppingPiece
  
  def initialize(location, color, board)
    @symbol = { "black" => "\u2654", "white" => "\u265a" }
    super
  end
  
  def move_dirs
    KING_MOVES
  end
end


class Pawn < Piece
  
  PAWN_DIAG = { "white" => [[1, 1], [1, -1]], "black" => [[-1, 1], [-1, -1]]}
  PAWN_STRAIGHT = {"white" => 1 , "black" => -1}
  
  def initialize(location, color, board)
    @symbol = { "black" => "\u2659", "white" => "\u265f" }
    super
  end
  
  def legal_moves
    cur_x = @location[0]
    cur_y = @location[1]
    legal = []
    pawn_start = { "white" => 1, "black" => 6 }
    
    pos = [cur_x + PAWN_STRAIGHT[@color], cur_y] 
    legal << pos if on_board?(pos) && !@board.occupied?(pos) 
    
    pos = [cur_x + (2 * PAWN_STRAIGHT[@color]), cur_y] 
    legal << pos if cur_x == pawn_start[@color] && !@board.occupied?(pos)
    
    PAWN_DIAG[@color].each do |direction|
      pos = [cur_x + direction[0], cur_y + direction[1]]
      legal << pos if @board.occupied?(pos) && !@board.occupied_my_color?(pos, self)
    end
  
    legal
  end
  
end
