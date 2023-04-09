class WordsController < ApplicationController
  def show
    word_data = Word.new(params[:word])
    render json: (word_data.word ? word_data : false)
  end
end
