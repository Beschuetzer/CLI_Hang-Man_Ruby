
require 'io/console'

class HangManGame
  @@chars_across = 50
  @@lines_down = 10
  @@section_width = 28
  @@valid_words = []

  def initialize(max_chances, max_word_size)
    @max_chances = max_chances
    @chances_left = @max_chances
    @max_word_size = max_word_size    
    setup_variables()
    populate_valid_words()
  end

  def start()
    print_instructions()
    get_secret_word    
    draw_grid
    while @chances_left > 0 do
      pick_letter
      draw_grid
      puts "@secret_word_display_string: #{@secret_word_display_string}"
      if !@secret_word_display_string.include?('_')
        print "Great job!  '#{@secret_word}' is the word.  Play again? " 
        break
      end

    end
    puts "You are out of guesses.  Play again? " if @chances_left <= 0
    ans = gets.chomp
    while !ans.match(/^\s*[yYnN]([eE][sS]|[oO])*\s*$/) do                                  
      print "Play again?  Available options are 'y' and 'n': "
      ans = gets.chomp.downcase
    end 
    if ans.match(/y/)
      setup_variables
      start
    end

    #start playing
  end

  private
  def setup_variables()
    @letters_available = []
    "a".upto("z"){|char| 
      @letters_available << char
    }
    @letters_guessed_correctly = []
    @chances_left = @max_chances
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
    @secret_word_display_string = "_ " * @secret_word.length
    if @letters_guessed_correctly.length != 0
      chars_in_secret_word = @secret_word.split('')
      #puts "secret word split: #{chars_in_secret_word} and @letters_guessed_correctly #{@letters_guessed_correctly}"
      chars_in_secret_word.each_index {|index|
        #puts "@secret_word_display_string[index*2+1]: #{@secret_word_display_string}[index*2+1] and chars_in_secret_word[index]: #{chars_in_secret_word[index]}"
        @secret_word_display_string[index*2] = chars_in_secret_word[index] if @letters_guessed_correctly.include?(chars_in_secret_word[index].downcase)
      }
    end
    @grid_section_word << (@secret_word_display_string).center(@@section_width)
    add_empty_line_to_grid_section(@grid_section_word)
    @grid_section_word << "Guesses: #{@chances_left}".center(@@section_width)
  end

  def get_grid_section_letters()
    split_across_n_lines = 3
    chars_per_line = (@letters_available.length / split_across_n_lines) + 1

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

  def draw_grid
    #gets all grid sections, combines, and displays
    @grid_section_word = []
    @grid_section_letters = []
    @grid_section_hangman = []
    @grid = []

    get_grid_section_word
    get_grid_section_letters
    get_grid_section_hangman
    combine_grids()

    @grid.each{|line|
      puts line
    }
    puts ""
    # line = " " * @@chars_across
    # @@lines_down.times {@grid << line}
    # puts @grid
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

  def pick_letter()
    #get the letter, update choices,
    begin
      print "Pick an available letter: "

      next_letter = gets.chomp.to_s
    end while !next_letter.match(/[a-zA-Z]/) || !@letters_available.include?(next_letter)
    #do stuff depending on whether letter is in secret word
    @letters_available -= [next_letter]
    if @secret_word.include?(next_letter)
      @letters_guessed_correctly += [next_letter]
      indexes_of_letters_to_show = find_indexes_of_letter(next_letter)
      #puts "next_letter: #{next_letter} and @letters_available: #{@letters_available}, and @letters_guessed_correctly: #{@letters_guessed_correctly}"
    else
      @chances_left -= 1
    end
  end

  def add_empty_line_to_grid_section(grid_section)
    grid_section << " " * @@section_width
  end

  def find_indexes_of_letter(next_letter)
    indexes_of_letters_to_show = []

    indexes_of_letters_to_show
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