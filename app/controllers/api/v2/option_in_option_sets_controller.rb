module Api
  module V2
      class OptionInOptionSetsController < ApiApplicationController
        respond_to :json

        def index
          if !params[:option_set_id].blank?
            option_set = OptionSet.find(params[:option_set_id])
            respond_with option_set.option_in_option_sets
          elsif !params[:instrument_id].blank?
            instrument = Instrument.find(params[:instrument_id])
            respond_with instrument.option_in_option_sets
          end

        end

        def create
          if !params[:option_set_id].blank?
            option_set = OptionSet.find(params[:option_set_id])
            option_in_option_set = option_set.option_in_option_sets.new(option_in_option_set_params)
            if option_in_option_set.save
              render json: option_in_option_set, status: :created
            else
              render json: { errors: option_in_option_set.errors.full_messages }, status: :unprocessable_entity
            end
          end
        end

        def update
          if !params[:option_set_id].blank?
            option_set = OptionSet.find(params[:option_set_id])
            option_in_option_set = option_set.option_in_option_sets.find(params[:id])
            respond_with option_in_option_set.update_attributes(option_in_option_set_params)
          end
        end

        def destroy
          if !params[:option_set_id].blank?
            option_set = OptionSet.find(params[:option_set_id])
            option_in_option_set = option_set.option_in_option_sets.find(params[:id])
            respond_with option_in_option_set.destroy
          end
        end

        private
        def option_in_option_set_params
          params.require(:option_in_option_set).permit(:option_set_id, :option_id,
            :number_in_question, :is_exclusive)
        end
      end
  end
end
