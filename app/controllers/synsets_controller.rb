class SynsetsController < ApplicationController
  def show
    @synset = Synset.new(params[:pos], params[:pos_offset].to_i)
    render json: @synset.as_json_with_synonyms(exclude_from_synonyms: params[:word])
  end
end
