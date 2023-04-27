class WordsController < ApplicationController
  def show
    word_data = Word.new(params[:word])
    return render json: { errors: word_data.errors }, status: :unprocessable_entity if word_data.errors

    render json: (word_data.word ? word_data : false)
  end
end
