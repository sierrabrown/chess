require "./piece.rb"
require "colorize"

class Board
  attr_accessor :board
  
  COLORS =  [:black, :light_blue]
  
  def initialize
   @board = Array.new(8) { Array.new(8)} 
  end
  
  def seed
    color = { 0 => "white", 7 => "black" }
    [0,7].each do |i|
      @board[i][0] = Rook.new([i,0], color[i], self)
      @board[i][7] = Rook.new([i,0], color[i], self)
      @board[i][1] = Knight.new([i,1], color[i], self)
      @board[i][6] = Knight.new([i,6], color[i], self)
      @board[i][2] = Bishop.new([i,2], color[i], self)
      @board[i][5] = Bishop.new([i,5], color[i], self)
      @board[i][3] = Queen.new([i,3],  color[i], self)
      @board[i][4] = King.new([i,4],  color[i], self)
    end
    pawn = { 1 => "white", 6 => "black"}    
    (0..7).each do |y|
      [1, 6].each do |x|
        @board[x][y] = Pawn.new([x, y], pawn[x], self)
      end
    end
  end
  
  
  def get_all_pieces(color)
    @board.flatten.compact.select { |piece| piece.color == color }
  end
  
  def find_king(color)
    get_all_pieces(color).find{ |x| x.is_a?(King) } 
  end
  
  def display
    print " "
    (0..7).each { |num| print " #{num} " }
    puts
    @board.each_with_index do |row, row_index|
      print row_index
      row.each_with_index do |square, col_index|
        color = COLORS[(row_index + col_index) % 2]
        if square.nil? 
          print "   ".colorize(background: color)
        else 
          print " #{square.symbol[square.color]} ".colorize(background: color)
        end
      end
      puts
    end
  end
  
  def occupied?(location)
   !@board[location[0]][location[1]].nil? 
  end
    
  def occupied_my_color?(location, piece)
    occupied?(location) && @board[location[0]][location[1]].color == piece.color
  end
  
  def in_check?(color)
    color == "white" ? opp_color = "black" : opp_color = "white"
    opp_pieces = self.get_all_pieces(opp_color)
    my_king = self.find_king(color).location
    opp_pieces.each do |opponent|
      return true if opponent.legal_moves.include?(my_king)
    end
    false
  end
  
  def move(start, end_pos)
    if @board[start[0]][start[1]].nil?
      raise InvalidMoveError.new("No piece to move.")
    elsif !@board[start[0]][start[1]].valid_moves.include?(end_pos)
      raise InvalidMoveError.new("That piece can't move there.")
    else
      move!(start, end_pos)
    end
  end
  
  def move!(start, end_pos)
    @board[start[0]][start[1]].location = end_pos
    @board[start[0]][start[1]], @board[end_pos[0]][end_pos[1]] = nil, @board[start[0]][start[1]]
  end
  
  def deep_dup
    dup_grid = Board.new
    @board.each_with_index do |row, row_idx|
      row.each_with_index do |square, col_idx|
        unless square.nil? 
          duped_piece = square.class.new([row_idx, col_idx], square.color, dup_grid)
          dup_grid.board[row_idx][col_idx] = duped_piece
        end
      end
    end
    dup_grid
  end
  
  
end

# 
# b = Board.new
# b.seed
# b.display
# b.move!([1,3],[2,0])
# b.move!([1,5],[3,0])
# b.move!([7,3],[1,3])
# b.move!([7,5], [3,7])
# b.move!([7,0], [5,3])
# 
# b.display
# 
# p "checkmate = #{b.board[0][4].checkmate?} "
