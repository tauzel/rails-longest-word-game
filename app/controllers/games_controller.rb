require 'open-uri'
require 'json'
require 'set'

class GamesController < ApplicationController

  def new
    n_grid = 10
    n_vowels = (n_grid * 3 / 6.5).to_i
    n_conson = n_grid - n_vowels
    grid = []
    n_vowels.times { grid << "aeiouy".chars.sample.capitalize }
    n_conson.times { grid << "bcdfghjklmnpqrstvwxz".chars.sample.capitalize }
    @letters = grid.shuffle!
    @start_time = Time.now
  end

  def score
    end_time = Time.now
    # convert start_time back into timestamp (came as string from the form)
    start_time = DateTime.parse(params[:start_time])
    @result = run_game(params[:answer], params[:grid], start_time, end_time)
  end

  private

  ###############################################################
  # SCORE CALCULATION METHODS

  def run_game(answer, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result (with `:score`, `:message` and `:time` keys)
    {
      score: calc_score(answer, grid, start_time, end_time),
      message: message(answer, grid, start_time, end_time),
      time: end_time - start_time
    }
  end

  def test_answer_letters(answer, grid)
    # check whether answer is a subset of grid
    # BOOLEAN: returns true/flase

    # turn grid into an array + sort into alphabetical order
    grid = grid.downcase.split(' ')
    grid2 = grid.sort

    # iterate over answer and delete letter whenever matches 1 of grid's
    answer.chars.sort!.each do |letter_a|
      grid2.each_with_index do |letter_g, i|
        grid2.delete_at(i) if letter_a.downcase == letter_g.downcase
      end
    end

    grid2.size == grid.size - answer.length
  end

  def test_answer_dico(answer)
    # call the API to check if word is english
    # BOOLEAN: returns true/false
    url = "https://wagon-dictionary.herokuapp.com/#{answer}"
    json_serialized = URI.open(url).read
    json_data = JSON.parse(json_serialized)
    # API returns true/false directly if word matches dictionnary
    json_data["found"]
  end

  def calc_score(answer, grid, start_time, end_time)
    # calculate score in function of own custom rules
    if test_answer_letters(answer, grid) && test_answer_dico(answer)
      score = (answer.size ** 1.5) - ((end_time - start_time) * 0.001)
      score.positive? ? score : 0
    else
      0
    end
  end

  def message(answer, grid, start_time, end_time)
    if test_answer_letters(answer, grid) == false
      "It's not in the grid mate!"
    elsif test_answer_dico(answer) == false
      "That's not an English word..."
    else
      # own customizations
      case calc_score(answer, grid, start_time, end_time)
        when 0..2.5
          "C'mon, you can do better"
        when 2.5..5
          "Well done! a little' faster maybe?"
        else
          "Outstanding!"
        end
    end
  end
end
