module Api
  module V2
    class OptionsController < ApiApplicationController
      include Syncable

      def index
        project = Project.find(params[:project_id])
        options = to_sync(project.options.includes(:grid_label, question: [:instrument]), 'options',
                          params[:last_sync_time]) #TODO seems like a terrible idea??
        render json: options.includes(:translations)
      end

      def show
        render json: Option.find(params[:id])
      end
    end
  end
end