class Game
  attr_accessor :partial_word, :guesses
  attr_reader :player1, :player2

  def initialize
  end

end


class Player

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


  def guess(partial_word, guesses)
    puts "you have guessed #{guesses.uniq}"
    puts "you see #{partial_word}"
    puts "what letter would you like to guess?"
    return gets.chomp
  end

end

class ComputerPlayer < Player
  attr_accessor :dictionary #array of words
  attr_writer :secret_word

  def initialize(dict_file_name = './dictionary.txt')
    @dictionary = File.new(dict_file_name).readlines.map(&:chomp)
  end

  def pick_secret_word(length = nil)
    self.secret_word = self.dictionary.sample
    return nil if length.nil?

    self.secret_word = self.dictionary
    .select{ |word| word.size == length }.sample

    nil
  end

  def guess
    raise NotImplementedError.new
  end

  def check_guess(guesses)
    @secret_word.gsub(/[^#{guesses}]/, '_')
  end

  def handle_guess_response
    raise NotImplementedError.new
  end

end

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



