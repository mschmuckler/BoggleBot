# A bot for finding all the words on a Boggle board and
# printing them out with score values.

class BoggleBot

  attr_reader :board, :dictionary
  def initialize(board, dictionary)
    @board = board
    @dictionary = filter_length(dictionary)
    @current_position = []
    @cells_visited = []
    @partial_word = ""
  end

  DELTAS = [
    [-1, -1],
    [-1, 0],
    [-1, 1],
    [0, -1],
    [0, 1],
    [1, -1],
    [1, 0],
    [1, 1]
  ]

  def print_words_with_score
    total_score = 0
    scoreboard = {
      1 => [],
      2 => [],
      3 => [],
      4 => [],
      11 => []
    }
    find_words.each do |word|
      if word.length <= 4
        scoreboard[1] << word
      elsif word.length == 5
        scoreboard[2] << word
      elsif word.length == 6
        scoreboard[3] << word
      elsif word.length == 7
        scoreboard[4] << word
      else
        scoreboard[11] << word
      end
    end
    scoreboard.each do |score, words|
      total_score += words.count * score
      puts "#{score} points: (#{words.count * score})"
      words.each { |word| puts word }
      puts "\n"
    end
    puts "Total score: #{total_score}"
  end

  def find_words
    words_found = []
    @dictionary.each do |word|
      words_found << word if on_board?(word)
    end
    words_found
  end

  def on_board?(word)
    is_on_board = nil
    start_positions = locate_start_positions(word)
    start_positions.each do |position|
      @cells_visited = []
      @partial_word = word[0]
      if word[0] == 'Q'
        @partial_word << 'U'
        letter_index = 2
      else
        letter_index = 1
      end
      is_on_board = next_positions([position], word, letter_index)
      break if is_on_board
    end
    is_on_board
  end

  def next_positions(current_cell, word, letter_index)
    possible_cells = []
    @current_position = current_cell[0]
    @cells_visited << current_cell[0]
    possible_cells = locate_nearby_cells(word[letter_index])
    return false if possible_cells == []
    @partial_word << self[possible_cells[0]]
    @partial_word << 'U' if self[possible_cells[0]] == 'Q'
    return true if @partial_word == word
    possible_cells.each do |cell|
      if self[cell] == 'Q'
        next_positions([cell], word, letter_index + 2)
      else
        next_positions([cell], word, letter_index + 1)
      end
      break if @partial_word == word
      @cells_visited.pop
    end
    return true if @partial_word == word
    @partial_word = @partial_word[0...-1]
    false
  end

  def locate_nearby_cells(letter)
    cell_positions = []
    cell_positions << up if valid_next_cell?(up, letter)
    cell_positions << up_right if valid_next_cell?(up_right, letter)
    cell_positions << right if valid_next_cell?(right, letter)
    cell_positions << down_right if valid_next_cell?(down_right, letter)
    cell_positions << down if valid_next_cell?(down, letter)
    cell_positions << down_left if valid_next_cell?(down_left, letter)
    cell_positions << left if valid_next_cell?(left, letter)
    cell_positions << up_left if valid_next_cell?(up_left, letter)
    cell_positions
  end

  def locate_start_positions(word)
    start_positions = []
    @board.each_with_index do |row, i1|
      row.each_with_index do |_cell, i2|
        start_positions << [i1, i2] if @board[i1][i2] == word[0]
      end
    end
    start_positions
  end

  def valid_next_cell?(position, letter)
    self[position] == letter && !@cells_visited.include?(position)
  end

  def up
    [@current_position[0] - 1, @current_position[1]]
  end

  def up_right
    [@current_position[0] - 1, @current_position[1] + 1]
  end

  def right
    [@current_position[0], @current_position[1] + 1]
  end

  def down_right
    [@current_position[0] + 1, @current_position[1] + 1]
  end

  def down
    [@current_position[0] + 1, @current_position[1]]
  end

  def down_left
    [@current_position[0] + 1, @current_position[1] - 1]
  end

  def left
    [@current_position[0], @current_position[1] - 1]
  end

  def up_left
    [@current_position[0] - 1, @current_position[1] - 1]
  end

  def filter_length(dictionary)
    filtered_dict = []
    dictionary.each do |word|
      filtered_dict << word if word.length >= 3
    end
    filtered_dict
  end

  def display_board
    @board.each do |row|
      row.each do |char|
        print "|" + char.upcase
      end
      puts "|\n"
    end
  end

  def convert_to_board
    puts "Enter board in 16 letter string"
    string = gets.chomp
    board = [[],[],[],[]]
    string.split("").each_with_index do |char, index|
      board[index / 4] << char
    end
    @board = board
  end

  def [](position)
    board_rows = board.count
    board_cols = board[0].count
    row = position[0]
    col = position[1]
    if row < 0
      return nil
    elsif row >= board_rows
      return nil
    elsif col < 0
      return nil
    elsif col >= board_cols
      return nil
    else
      @board[row][col]
    end
  end

end

if $PROGRAM_NAME == __FILE__
  dictionary = File.read('dictionary.txt').split("\n")
  board = [['Y','H','E','J'],
           ['T','S','S','O'],
           ['L','A','A','C'],
           ['M','H','N','T']]
  bot = BoggleBot.new(board, dictionary)
  bot.display_board
  now = Time.now
  bot.print_words_with_score
  p Time.now - now
end
