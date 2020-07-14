require 'io/console'
$guesses = 8
$max_word_size = 12

class HangManGame
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
    get_play_style()
    draw_grid
    while @chances_left > 0 do
      pick_letter
      draw_grid
      if !@secret_word_display_string.include?('_')
        print "Great job!  '#{@secret_word}' is the word.  Play again? " 
        break
      end
    end

    puts "'#{@secret_word}' was the word.  Play again? " if @chances_left <= 0
    ans = gets.chomp
    while !ans.match(/^\s*[yYnN]([eE][sS]|[oO])*\s*$/) do                                  
      print "Play again?  Available options are 'y' and 'n': "
      ans = gets.chomp.downcase
    end 
    if ans.match(/y/)
      setup_variables
      start
    end
  end

  private
  def get_play_style
    play_against_computer = yes_no_prompt("Would you like to play against the Computer?")
    if play_against_computer == 'y'
      @secret_word = get_random_word_from_valid_words
    else
      get_secret_word    
    end
  end

  def setup_variables()
    @letters_guessed_incorrectly = []
    @letters_available = []
    "a".upto("z"){|char| 
      @letters_available << char
    }
    @letters_guessed_correctly = []
    @chances_left = @max_chances
    @grid_section_word = []
    @grid_section_letters = []
    @grid_section_guessed_incorrectly = []
    @grid_section_hangman = []
  end

  def populate_valid_words()
    file = open("./words.txt").readlines
    file.each{|line|
      @@valid_words  << line.split()[0].to_s
    }
  end

  def get_random_word_from_valid_words
    word = ""
    while !word.length.between?(5,@max_word_size)
      word = @@valid_words.sample()
    end
    word
  end

  def print_instructions
    msg = "\nHang-Man Instructions:"
    puts msg
    puts "-" * (msg.length - 1)
    puts "One person types in a word (only alpha characters are allowed a-z).  The other person tries to guess the word within #{@chances_left} guesses.  Maximum word size is #{@max_word_size}.\n\n"
  end

  def get_secret_word()
    begin
      print "Player 1, enter your secret word (only one word allowed): "
      @secret_word = STDIN.noecho(&:gets).chomp.strip
      puts "\n"
    end while @secret_word.split().length != 1 || @secret_word.length > @max_word_size || @secret_word.match(/^\s*[^A-Za-z]+\s*/) || !@@valid_words.any?{|word|word.downcase == @secret_word.to_s.downcase}
  end

  def get_grid_section_word()
    add_empty_line_to_grid_section(@grid_section_word)
    @grid_section_word << "SECRET WORD:".center(@@section_width-1)
    @secret_word_display_string = "_ " * @secret_word.length
    if @letters_guessed_correctly.length != 0
      chars_in_secret_word = @secret_word.split('')
      chars_in_secret_word.each_index {|index|
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
    @grid_section_letters << "  LETTERS AVAILABLE:".center(@@section_width)
    i = 1
    start_index = 0
    split_across_n_lines.times{
      end_index = chars_per_line * i - 1
      line = @letters_available[start_index..end_index].join(', ').center(@@section_width)
      @grid_section_letters << line
      start_index = end_index + 1
      i += 1
    }
    add_empty_line_to_grid_section(@grid_section_letters)

  end

  def get_grid_section_guessed_already()
    split_across_n_lines = 3
    chars_per_line = (@letters_available.length / split_across_n_lines) + 1

    add_empty_line_to_grid_section(@grid_section_guessed_incorrectly)
    @grid_section_guessed_incorrectly << "  GUESSED ALREADY:".center(@@section_width)
    @letters_guessed_incorrectly.sort!
    if @letters_guessed_incorrectly.length <= 6
      line = @letters_guessed_incorrectly.join(', ').center(@@section_width)
      @grid_section_guessed_incorrectly << line
      add_empty_line_to_grid_section(@grid_section_guessed_incorrectly)
    elsif @letters_guessed_incorrectly.length.between?(6,12)
      line = @letters_guessed_incorrectly[0..5].join(', ').center(@@section_width)
      @grid_section_guessed_incorrectly << line
      line = @letters_guessed_incorrectly[6..11].join(', ').center(@@section_width)
      @grid_section_guessed_incorrectly << line
    else
      line = @letters_guessed_incorrectly[0..5].join(', ').center(@@section_width)
      @grid_section_guessed_incorrectly << line
      line = @letters_guessed_incorrectly[6..11].join(', ').center(@@section_width)
      @grid_section_guessed_incorrectly << line
      line = @letters_guessed_incorrectly[12..(@letters_guessed_incorrectly.length-1)].join(', ').center(@@section_width)
      @grid_section_guessed_incorrectly << line
    end
    add_empty_line_to_grid_section(@grid_section_guessed_incorrectly)
  end

  def get_grid_section_hangman()
    @grid_section_hangman << (" " * 10 + "_" * 9).center(@@section_width)
    @grid_section_hangman << (" " * 12 + "|" + " " * 9 + "|").center(@@section_width)
    @grid_section_hangman << (" " * 10 + "O" + " " * 9 + "|").center(@@section_width)
    line3 = ""
    substr = ""
    base = "____|____"
    case @chances_left
    when 5
      substr = "|"
      line2 = (" " * (10-(5-@chances_left)) + substr + " " * 9 + "|").center(@@section_width)
    when 4
      substr = "/|"
      line2 = (" " * (10-(5-@chances_left)) + substr + " " * 9 + "|").center(@@section_width)
    when 3
    when 2
      substr = "|"
      line3 = (" " * (16-(5-@chances_left)) + substr + " " * 5 + base).center(@@section_width)
    when 1
      substr = "_| "
      line3 = (" " * (16-(5-@chances_left)) + substr + " " * 4 + base).center(@@section_width)
    when 0
      substr = "_|_"
      line3 = (" " * (17-(5-@chances_left)) + substr + " " * 4 + base).center(@@section_width)
    else
      substr = "|"
      line2 = (" " * (10) + substr + " " * 9 + "|").center(@@section_width)
    end

    if @chances_left.between?(3,@max_chances)
      line3 = " " * 10 + "____|____".center(@@section_width)
    end

    if @chances_left.between?(0,3)
      substr = "/|\\"
      line2 = (" " * 9 + substr + " " * 8 + "|").center(@@section_width)
    end

    @grid_section_hangman << line2
    @grid_section_hangman << line3

  end

  def draw_grid
    @grid_section_word = []
    @grid_section_letters = []
    @grid_section_guessed_incorrectly = []
    @grid_section_hangman = []
    @grid = []

    get_grid_section_word
    get_grid_section_letters
    get_grid_section_guessed_already
    get_grid_section_hangman
    combine_grids()

    @grid.each{|line|
      puts line
    }
    puts ""
  end

  def combine_grids
    @grid_section_word.each_index{|index|
      new_line = @grid_section_word[index].to_s + @grid_section_letters[index].to_s + @grid_section_guessed_incorrectly[index].to_s  + @grid_section_hangman[index].to_s 
      @grid << new_line
    }
  end

  def pick_letter()
    begin
      print "Pick an available letter: "
      next_letter = gets.chomp.to_s
    end while !next_letter.match(/[a-zA-Z]/) || !@letters_available.any?{|letter| letter.downcase == next_letter.downcase}

    next_letter_as_array = [next_letter.downcase]
    @letters_available -= next_letter_as_array
    @letters_guessed_incorrectly += next_letter_as_array
    puts @secret_word.split('').any?{|char|
      char.downcase == next_letter.downcase
    }
    if @secret_word.split('').any?{|char| char.downcase == next_letter.downcase}
      @letters_guessed_correctly += next_letter_as_array
    else
      @chances_left -= 1
    end
  end

  def add_empty_line_to_grid_section(grid_section)
    grid_section << " " * @@section_width
  end

  def yes_no_prompt(msg)
    ans = ""
    while !ans.match(/^\s*[yYnN]([eE][sS]|[oO])*\s*$/) do
      print msg + "  Available options are 'y' and 'n': "
      ans = gets.chomp.downcase
    end
    ans
  end

end

hang_man_game = HangManGame.new($guesses, $max_word_size)
hang_man_game.start()