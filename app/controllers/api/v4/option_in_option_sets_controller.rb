# frozen_string_literal: true

class Api::V4::OptionInOptionSetsController < Api::V4::ApiController
  respond_to :json

  def destroy
    option_set = OptionSet.find(params[:option_set_id])
    option_in_option_set = option_set.option_in_option_sets.find(params[:id])
    respond_with option_in_option_set.destroy
  end

  private

  def option_in_option_set_params
    params.require(:option_in_option_set).permit(:option_set_id, :option_id,
                                                 :number_in_question, :special, :exclusion_ids)
  end
end
