module Api
  module V2
    class InstrumentRulesController < ApiApplicationController
      respond_to :json
      before_action :set_instrument_project, only: [:index, :create, :destroy]

      def index
        @instrument_rules = @instrument.instrument_rules
      end

      def show
        @instrument_rule = @instrument.instrument_rules.find params[:id]
      end

      def create
        ir = @instrument.instrument_rules.new(instrument_rule_params)
        if ir.save
          render json: ir, status: :created
        else
          render json: { errors: ir.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        ir = @instrument.instrument_rules.find(params[:id])
        respond_with ir.update_attributes(instrument_rule_params)
      end

      def destroy
        ir = @instrument.instrument_rules.find(params[:id])
        if ir.destroy
          render nothing: true, status: :ok
        else
          render json: { errors: ir.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_instrument_project
        @project = Project.find(params[:project_id])
        @instrument = @project.instruments.find(params[:instrument_id])
      end

      def instrument_rule_params
        params.require(:instrument_rule).permit(:instrument_id, :rule_id)
      end
    end
  end
end
