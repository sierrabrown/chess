require "./board.rb"
require "yaml"

class Game
  
  #Hi this is a chess game.
  attr_accessor :gameboard, :currentplayer
  
  def initialize
    @gameboard = Board.new
    @gameboard.seed
    @player1 = "white"
    @player2 = "black"
    @currentplayer = @player1
  end
      
  def next_turn
    @currentplayer == @player1 ? @player2 : @player1
  end
  
  def get_input
    start_pos = nil
    puts "#{@currentplayer.capitalize} enter location of piece or type 's' to save"
    start_pos = gets.chomp.split(", ")
    
    if start_pos[0] == 's'
      save_game? 
      get_input
    end
  
    start_pos.map! {|n| Integer(n) }
  
    raise InvalidMoveError.new("Not your piece.") if @gameboard.board[start_pos[0]][start_pos[1]].color != @currentplayer
    puts "Enter location to be moved to "
    end_pos = gets.chomp.split(", ").map { |n| Integer(n) }
    return [start_pos, end_pos]
  end
  
  def save_game?
    puts "Enter filename"
    filename = gets.chomp
    File.write(filename, YAML.dump(self) ) 
  end

       
  
  def player_move(positions)
    @gameboard.move(positions[0], positions[1])
  end
    
  def play_turn
    until @gameboard.find_king(@currentplayer).checkmate?
      @gameboard.display
      begin
        player_move(get_input)
      rescue InvalidMoveError => e
        puts e.message
        puts "Please try again."
        retry
      rescue ArgumentError => e
        puts e.message
        puts "Can't understand your input. Please try again."
        retry
      end
      @currentplayer = next_turn
    end
    @gameboard.display
    puts "Checkmate! #{@currentplayer.capitalize} loses."
  end
end


class InvalidMoveError < StandardError
end


if $PROGRAM_NAME == __FILE__
  # running as script

  case ARGV.count
  when 0
    Game.new.play_turn
  when 1
    # resume game, using first argument
    YAML.load_file(ARGV.shift).play_turn
  end
end
  


