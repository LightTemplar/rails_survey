module Api
  module V1
    class RostersController < ApiApplicationController
      respond_to :json

      def create
        roster = Roster.create(roster_params)
        roster.project = Project.find params[:project_id]
        if roster.save
          render json: roster, status: :created
        else
          render nothing: true, status: :unprocessable_entity
        end
      end

      private

      def roster_params
        params.require(:roster).permit(:instrument_id, :uuid, :instrument_version_number, :instrument_title, :identifier)
      end
    end
  end
end
