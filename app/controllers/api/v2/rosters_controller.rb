module Api
  module V2
    class RostersController < ApiApplicationController

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
        params.require(:roster).permit(:instrument_id, :instrument_version_number, :uuid, :instrument_title,
                                       :identifier)
      end
    end
  end
end