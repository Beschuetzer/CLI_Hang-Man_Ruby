
class Game
  def initialize
    
    @chars_available = "a".upto("z"){|char|puts char}
  end

  def play
    #start playing
  end

  private
  def draw
    #draw current state of game
  end

  def play(player)
    #get the play 
    raise "Player (#{player}) must be 1 or 2" if !player.between?(1,2)
  end
end

game = Game.new()
game.play