module Api
  module V1
    class RandomizedDisplayGroupsController < ApiApplicationController
      respond_to :json

      def index
        project = Project.find(params[:project_id])
        @randomized_display_groups = project.randomized_display_groups
      end

    end
  end
end
