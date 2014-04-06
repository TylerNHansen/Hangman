require 'set'
require 'time'

class Game
  attr_accessor :partial_word, :guesses
  attr_reader :guesser, :checker

  def initialize
    @guesser = ComputerPlayer.new
    @checker = HumanPlayer.new
    @guesses = ""
  end

  def play
    self.partial_word = "_" * self.checker.pick_secret_word


    make_guess
    loop do
      check_guess
      make_guess
      break if game_over?
    end

    puts self.partial_word
    puts guesser_won? ? "GUESSER WINS" : "GUESSER LOSES"

  end

  def guesser_won?
    !self.partial_word.include?('_')
  end

  def game_over?
    self.guesses.length > 10 || guesser_won?
  end

  def check_guess
    self.partial_word = self.checker.check_guess(self.guesses)
    nil
  end

  def make_guess
    self.guesses += self.guesser.guess(self.partial_word, self.guesses)
    nil
  end

end


class Player

  LETTERS = ("a".."z").to_a.join("")

  def pick_secret_word
    raise NotImplementedError.new
  end

  def receive_partial_secret
    raise NotImplementedError.new
  end

  def guess
    raise NotImplementedError.new
  end

  def check_guess
    raise NotImplementedError.new
  end

  def handle_guess_response
    raise NotImplementedError.new
  end

end

class HumanPlayer < Player
  attr_accessor :secret_length

  def pick_secret_word
    puts "how many letters in your word?"
    self.secret_length = gets.chomp.to_i
  end


  def guess(partial_word, guesses)
    puts "you have guessed #{guesses.chars.sort.to_a.join("")}"
    puts "you see #{partial_word}"
    puts "what letter would you like to guess?"

    guess = gets.chomp
    raise 'quitting at user request' if guess.downcase == 'quit'
    return guess
  end

  def check_guess(guesses)
    puts "the computer guessed #{guesses.chars.sort.to_a.join("")}"
    puts "please type the appropriate hangman string"
    partial_word = gets.chomp
    check_guess(guesses) unless valid_answer?(partial_word, guesses)
    partial_word
  end

  def valid_answer?(partial_word, guesses)
    return false if partial_word.include?(LETTERS.delete(guesses))
    return false unless partial_word.size == self.secret_length
    true
  end
end

class ComputerPlayer < Player
  attr_accessor :dictionary #set of words
  attr_writer :secret_word

  def initialize(dict_file_name = './dictionary.txt')
    @dictionary = Set.new(File.new(dict_file_name).readlines.map(&:chomp))
  end

  def pick_secret_word(length = nil)
    self.secret_word = self.dictionary.sample
    return nil if length.nil?

    self.secret_word = self.dictionary
    .select{ |word| word.size == length }.sample

    self.secret_word.size
  end

  def guess(partial_word, guesses)
    dict_filter(partial_word, guesses)
    wordcount = Hash.new{0}

    p "THERE ARE BUT #{self.dictionary.size} WORDS REMAINING"

    #for each letter in the alphabet that we haven't guessed,
    LETTERS.delete(guesses).chars.each do |char|
      #count how many words include it, and store that in the wordcount hash
      wordcount[char] = self.dictionary.count do |word|
        word.include?(char)
      end
    end
    wordcount.max_by {|key, value| value}[0]
  end


  def dict_filter(partial_word, guesses)
    open_letters = LETTERS.delete(guesses)
    self.dictionary.keep_if do |word|
      possible = true
      word.length.times do |ind|
        unless char_valid?(word[ind], guesses, partial_word[ind])
          possible = false
        end
      end
      possible = false unless word.size == partial_word.size
      possible
    end
    self.dictionary.size

  end

  #if target is _, returns false if we've guessed the word's char already
  #if target is a-z, returns false if our word has a different char
  def char_valid?(char, guesses, target)

    if target == '_'
      return !guesses.include?(char)
    end

    char == target
  end

  def check_guess(guesses, word = @secret_word)
    word.gsub(/[^#{guesses}_]/, '_')
  end

  def handle_guess_response
    raise NotImplementedError.new
  end

end

class SmartComputerPlayer < ComputerPlayer

  def guess(partial_word, guesses)
    cost_hash = self.make_cost_hash(partial_word, guesses)

  end

  def make_cost_hash(partial_word, guesses)
    start = Time.now
    cost_hash = Hash.new {Set.new}
    trim_dict(partial_word.size)

    puts "building a hash, this may take a minute"
    self.dictionary.each do |word|
      LETTERS.delete(guesses).chars.each do |chr|
        # p self.check_guess(guesses, word)
        cost_hash[chr + self.check_guess(guesses+chr, word)] += Set.new([word])
      end
    end

    puts "hash done, took #{Time.now - start}"

    cost_hash

  end

  def trim_dict(len)
    self.dictionary.delete_if { |word| word.size != len }
  end
end

    # dict_filter(partial_word, guesses)
    # wordcount = Hash.new{0}
    #
    # p "THERE ARE BUT #{self.dictionary.size} WORDS REMAINING"
    #
    # #for each letter in the alphabet that we haven't guessed,
    # LETTERS.delete(guesses).chars.each do |char|
    #   #count how many words include it, and store that in the wordcount hash
    #   wordcount[char] = self.dictionary.count do |word|
    #     word.include?(char)
    #   end
    # end
    # wordcount.max_by {|key, value| value}[0]
#   end
#
# end

class String
  def all_in_az?
    #if anything in the string isn't a character between a and z
    #  then it matches the regex and ~= will return where it is
    #otherwise, =~ returns nil
    self.match(/[^a-z]/).nil?
  end
end

def write_filtered_dict(in_name = nil, out_name = nil)
  in_name ||= './dictionary.txt'
  out_name ||= './dictionary.txt'

  words = File.new(in_name).map(&:chomp)
  puts "words in #{in_name}: #{words.size}"
  words.select!(&:all_in_az?)

  File.open(out_name, "w") do |outfile|
    words.each {|word| outfile.puts word }
    puts "words in #{out_name}: #{words.size}"
  end
  nil
end


