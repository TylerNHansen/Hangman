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
  end

end

class ComputerPlayer < Player
  attr_accessor :dictionary #array of words

  def trim_dictionary!
    @dictionary.select! do |word|
      word.match(/[^a-z]/).nil?
    end
  end


  def initialize(dict_file_name = './dictionary.txt')
    @dictionary = File.new(dict_file_name).readlines.map(&:chomp)
    trim_dictionary!
  end

  def pick_secret_word(length = nil)
    return self.dictionary.sample if length.nil?
    loop do
      word = self.dictionary.select{ |word| word.size == length }.sample
      return word unless word.include?("'")
    end
  end

end

class String
  def all_in_az?
    #if anything in the string isn't a character between a and z
    #  then it matches the regex and .match will return something
    #otherwise, .match returns nil
    self.match(/[^a-z]/).nil?
  end
end

def write_filtered_dict(in_name = nil, out_name = nil)
  in_name ||= './dictionary.txt'
  out_name ||= './dictionary2.txt'

  words = File.new(in_name).map(&:chomp)
  puts "words in #{in_name}: #{words.size}"
  words.select!(&:all_in_az?)

  outfile = File.new(out_name, "w")
  words.each {|word| outfile.puts word }
  puts "words in #{out_name}: #{words.size}"

  nil
end




