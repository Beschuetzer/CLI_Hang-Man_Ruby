
require 'io/console'

class HangManGame
  @@chars_across = 50
  @@lines_down = 10
  @@valid_words = []

  def initialize(chances, max_word_size)
    @chances = chances
    @max_word_size = max_word_size
    setup_variables()
    populate_valid_words()
  end

  def setup_variables()
    @chars_available = []
    "a".upto("z"){|char| 
      @chars_available << char
    }
    @chances_left_p1 = @chances
    @chances_left_p2 = @chances
    # print @chars_available
  end

  def start()
    print_instructions()
    get_secret_word
    draw
    #start playing
  end

  private
  def populate_valid_words()
    file = open("./words.txt").readlines
    file.each{|line|
      @@valid_words  << line.split()[0].to_s
    }
    # puts "@@valid_words.length: #{@@valid_words.length}"

    #makes sure the word is in the dictionary
  end

  def print_instructions
    msg = "\nHang-Man Instructions:"
    puts msg.ljust(@@chars_across)
    puts "-" * (msg.length - 1)
    puts "One person types in a word (only alpha characters are allowed a-z).  The other person tries to guess the word and has #{@chances} chances.".ljust(@@chars_across)
  end

  def get_secret_word()
    puts @@valid_words[1000]
    begin
      print "Player 1, enter your secret word (only one word allowed): "
      @secret_word = STDIN.noecho(&:gets).chomp.strip
      puts "\n"
      #puts "!@secret_word.split().length: #{@secret_word.split().length},  @secret_word.length: #{ @secret_word.length}, @max_word_size: #{@max_word_size}"
      #puts "Word: #{@secret_word}, #{@secret_word} not in Dict: #{!@@valid_words.include?(@secret_word.to_s)}, Only one word: #{@secret_word.split().length != 1 }, Too long: #{ @secret_word.length > @max_word_size}, and Invalid Char: #{@secret_word.match(/^\s*[^A-Za-z]+\s*/)}"
      # puts @@valid_words[rand(@@valid_words.length-1)]
    end while @secret_word.split().length != 1 || @secret_word.length > @max_word_size || @secret_word.match(/^\s*[^A-Za-z]+\s*/) || !@@valid_words.include?(@secret_word.to_s)
    puts "Secret word: #{@secret_word} and length: #{@secret_word.length}"
  end

  def draw
    @grid = []
    line = " " * @@chars_across
    @@lines_down.times {@grid << line}
    puts @grid
    #draw current state of game

  end

  def play(player)
    #get the play 
    raise "Player (#{player}) must be 1 or 2" if !player.between?(1,2)
  end


end

hang_man_game = HangManGame.new(5, 10)
hang_man_game.start()


# dict = open("./dict.txt").readlines
# i = 0
# dict.each{|l|
#   words = l.split()
#   if i <= 10000 && l.match(/[a-zA-Z]*/)

#     puts words[0]
#   else
#     break
#   end
#   i+=1
# }