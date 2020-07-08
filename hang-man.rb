
require 'io/console'

class HangManGame
  @@chars_across = 50
  @@lines_down = 10
  @@section_width = 28
  @@valid_words = []

  def initialize(chances_left, max_word_size)
    @chances_left = chances_left
    @max_word_size = max_word_size    
    setup_variables()
    populate_valid_words()
  end

  def start()
    print_instructions()
    get_secret_word    
    draw_grid
    #start playing
  end

  private
  def setup_variables()
    @letters_available = []
    "a".upto("z"){|char| 
      @letters_available << char
    }
    @letters_guessed_correctly = []
    @chances_left_left = @chances_left
    @grid = []
    @grid_section_word = []
    @grid_section_letters = []
    @grid_section_hangman = []
  end

  def populate_valid_words()
    #makes sure the word is in the dictionary
    file = open("./words.txt").readlines
    file.each{|line|
      @@valid_words  << line.split()[0].to_s
    }
    # puts "@@valid_words.length: #{@@valid_words.length}"
  end

  def print_instructions
    msg = "\nHang-Man Instructions:"
    puts msg.ljust(@@chars_across)
    puts "-" * (msg.length - 1)
    puts "One person types in a word (only alpha characters are allowed a-z).  The other person tries to guess the word and has #{@chances_left} chances_left.".ljust(@@chars_across)
  end

  def get_secret_word()
    begin
      print "Player 1, enter your secret word (only one word allowed): "
      @secret_word = STDIN.noecho(&:gets).chomp.strip
      puts "\n"
      #puts "!@secret_word.split().length: #{@secret_word.split().length},  @secret_word.length: #{ @secret_word.length}, @max_word_size: #{@max_word_size}"
      #puts "Word: #{@secret_word}, #{@secret_word} not in Dict: #{!@@valid_words.include?(@secret_word.to_s)}, Only one word: #{@secret_word.split().length != 1 }, Too long: #{ @secret_word.length > @max_word_size}, and Invalid Char: #{@secret_word.match(/^\s*[^A-Za-z]+\s*/)}"
      # puts @@valid_words[rand(@@valid_words.length-1)]
    end while @secret_word.split().length != 1 || @secret_word.length > @max_word_size || @secret_word.match(/^\s*[^A-Za-z]+\s*/) || !@@valid_words.include?(@secret_word.to_s)
    #puts "Secret word: #{@secret_word} and length: #{@secret_word.length}"
  end

  def get_grid_section_word()
    #section 1: chances_left and secret word
    add_empty_line_to_grid_section(@grid_section_word)
    @grid_section_word << "SECRET WORD".center(@@section_width-1)
    if @letters_guessed_correctly.length != 0
      #need to dynamically create this based on @letters_guessed_correctly
      puts 'Not yet implemented'
    else
      substr = "_ " * @secret_word.length
      @grid_section_word << (substr).center(@@section_width)
    end
    add_empty_line_to_grid_section(@grid_section_word)
    @grid_section_word << "Guesses: #{@chances_left}".center(@@section_width)
  end

  def get_grid_section_letters()
    split_across_n_lines = 3
    chars_per_line = (@letters_available.length / split_across_n_lines) + 1
    puts "chars_per_line: #{chars_per_line}"

    add_empty_line_to_grid_section(@grid_section_letters)
    @grid_section_letters << "LETTERS AVAILABLE:".center(@@section_width)
    i = 1
    start_index = 0
    split_across_n_lines.times{
      end_index = chars_per_line * i - 1
      line = @letters_available[start_index..end_index].join(', ').center(@@section_width)
      @grid_section_letters << line
      #puts "start_index: #{start_index}, end_index: #{end_index}, and line: #{line}"
      start_index = end_index + 1
      i += 1
    }
    add_empty_line_to_grid_section(@grid_section_letters)

  end

  def get_grid_section_hangman()


  end

  def combine_grids
    @grid_section_word.each_index{|index|
      new_line = @grid_section_word[index].to_s + @grid_section_letters[index].to_s + @grid_section_hangman[index].to_s 
      #puts "@grid_section_word[index]: #{@grid_section_word[index]}, @grid_section_letters[index]: #{@grid_section_letters[index]}, @grid_section_hangman[index]: #{@grid_section_hangman[index]}, "
      # puts "Index: #{index}"
      # puts "new_line #{index}: #{new_line}"
      @grid << new_line
    }
  end

  def draw_grid
    #gets all grid sections, combines, and displays
    get_grid_section_word
    get_grid_section_letters
    get_grid_section_hangman
    combine_grids()

    @grid.each{|line|
      puts line
    }
    # line = " " * @@chars_across
    # @@lines_down.times {@grid << line}
    # puts @grid
  end

  def play(player)
    #get the letter, update choices,
    raise "Player (#{player}) must be 1 or 2" if !player.between?(1,2)
  end

  def add_empty_line_to_grid_section(grid_section)
    grid_section << " " * @@section_width
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