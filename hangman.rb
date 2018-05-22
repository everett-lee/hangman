
require "json"

random_num = rand(44043)
game_word = nil
File.open("dictionary.txt", "r") do |file|
  while game_word == nil
    file.readlines.each_with_index do |word, index|
      if index == random_num
        game_word = word.downcase
      end
    end
  end
  file.close
end

class Picture
  def initialize
    @hang_arr = [["0000000000000"], ["0           0"], ["0           1"], ["0          1 1"], ["0           1"], ["0          324"],
    ["0         3 2 4"], ["0        3  2  4"], ["0          5 6"], ["0         5   6"], ["0        5     6"], ["0       5       6"]]
  end

  def print(step)
    step.times {|part| puts @hang_arr[part]}
  end
end

class Game
  attr_accessor :guess, :word, :blank_word, :split_word, :guessed_letters
  def initialize(word=game_word)
    @word = word
    @split_word = @word.split("")
    @blank_word = @word.gsub(/\w/, "_")
    @guessed_letters = []
  end

  #finds string index(es) for chosen letter
  def letter_index(letter)
    @places = []
    @split_word.each_with_index do |char, index|
      if char == letter
        @places << index
      end
    end
  end

  def get_guess
    print "\n"
    print "Please enter a letter A-Z, or enter to save and exit: "
    @guess = gets.chomp.downcase
    if @guess == ""
      @guess
    else
      print "\n"
      while @guess.scan(/[a-z]/).length != 1 || @guessed_letters.include?(@guess)
        print "That is an invalid or repeated guess, please choose another letter: "
        @guess = gets.chomp.downcase
        print "\n"
      end
    end
    @guess
  end

  def guess_update
    letter_index(@guess)
    @guessed_letters << @guess
    if @split_word.include?(@guess)
      @places.each do |place|
        @blank_word[place] = @guess
      end
    else
      return false
    end
  end

  def printer
    print "\n"
    puts @blank_word
    print "\n"
    print "You have guessed: "
    @guessed_letters.each {|letter| print letter + " "}
    print "\n"
  end
end

class Hangman
  def initialize(game_word)
      @picture = Picture.new
      @game = Game.new(game_word)
      self.lives
      self.run_game
  end

  def save_game
    save = JSON.dump ({
      :lives => @lives,
      :word => @game.word,
      :blank_word => @game.blank_word,
      :guessed_letters => @game.guessed_letters
    })

    File.open("saved_game.json", "w") { |file| file.write(save) }
  end

  def load_game
    data = File.read "saved_game.json"
    data_hash = JSON.parse(data)

    @lives = data_hash["lives"]
    @game.word = data_hash["word"]
    @game.split_word = @game.word.split("")
    @game.blank_word = data_hash["blank_word"]
    @game.guessed_letters = data_hash["guessed_letters"]
  end

  protected
  def run_game
    print "Welcome to Hangman! \n"
    print "Would you like to load your last game? Y/N: "
    if gets.chomp.downcase == "y"
      load_game
      @game.printer
    end
    @on = true
    while @on
      play_game
      #game lost
      if @lives == 0
        print "\n"
        puts "Sorry, you have lost.The word was #{@game.word}"
        @on = false
      #game won
      elsif @game.blank_word.include?("_") == false
        puts "You guessed the word!"
        @on = false
      end
    end
  end

  def play_game
    if @game.get_guess == ""
      @on = false
      save_game
    else
      if @game.guess_update == false
        @lives -= 1
        @picture.print(12 - (@lives * 2))
        @game.printer
      else
        @game.printer
      end
    end
  end

  def lives
    @lives = 6
  end
end

Hangman.new(game_word)
