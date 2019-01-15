module Api
  module V2
    class RulesController < ApiApplicationController
      respond_to :json
      before_action :set_rule, only: [:update, :show, :destroy]

      def index
        respond_with Rule.all
      end

      def show
        respond_with @rule
      end

      def create
        rule = Rule.new(rule_params)
        if rule.save
          render json: rule, status: :created
        else
          render json: { errors: rule.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        respond_with @rule.update_attributes(rule_params)
      end

      def destroy
        if @rule.destroy
          render nothing: true, status: :ok
        else
          render json: { errors: rule.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_rule
        @rule = Rule.find(params[:id])
      end

      def rule_params
        params.require(:rule).permit(:rule_type, :rule_params)
      end
    end
  end
end
