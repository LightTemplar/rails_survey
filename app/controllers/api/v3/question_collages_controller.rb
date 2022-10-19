# frozen_string_literal: true

module Api
  module V3
    class QuestionCollagesController < Api::V1::ApiApplicationController
      include Syncable
      respond_to :json
      def index
        @project = Project.find(params[:project_id])
        @question_collages = to_sync(@project.api_question_collages, 'question_collages', params[:last_sync_time])
      end
    end
  end
end
