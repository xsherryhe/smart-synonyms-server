class WordsController < ApplicationController
  def show
    render json: Word.new(params[:word]).glosses
  end
end
