class SynsetsController < ApplicationController
  def show
    @synset = Synset.new(params[:pos], params[:pos_offset].to_i, params[:word])
    render json: @synset.as_json_with_synonyms
  end
end
