module Api
  module V2
      class OptionsController < ApiApplicationController
        respond_to :json
        before_action :set_option_set

        def index
          respond_with @option_set.options
        end

        def create
          option = @option_set.options.new(option_params)
          if option.save
            render json: option, status: :created
          else
            render json: { errors: option.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def update
          option = @option_set.options.find(params[:id])
          respond_with option.update_attributes(option_params)
        end

        def destroy
          option = @option_set.options.find(params[:id])
          respond_with option.destroy
        end

        private

        def set_option_set
          @option_set = OptionSet.find(params[:option_set_id])
        end

        def option_params
          params.require(:option).permit(:option_set_id, :text)
        end
      end
  end
end
