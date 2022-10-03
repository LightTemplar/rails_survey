# frozen_string_literal: true

module Api
  module V3
    class TasksController < Api::V1::ApiApplicationController
      include Syncable
      respond_to :json
      def index
        @project = Project.find(params[:project_id])
        @tasks = to_sync(@project.tasks, 'tasks', params[:last_sync_time])
      end
    end
  end
end
