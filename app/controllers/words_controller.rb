class WordsController < ApplicationController
  def show
    render json: Word.new(params[:word])
  end
end
