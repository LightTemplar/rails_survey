# frozen_string_literal: true

module Api
  module V3
    class LoopQuestionsController < Api::V1::ApiApplicationController
      include Syncable
      respond_to :json
      def index
        @project = Project.find(params[:project_id])
        @loop_questions = to_sync(@project.loop_questions, 'loop_questions', params[:last_sync_time])
      end
    end
  end
end
