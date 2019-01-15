module Api
  module V2
    class InstrumentNextQuestionsController < ApiApplicationController
      respond_to :json

      def index
        project = Project.find params[:project_id]
        instrument = project.instruments.find params[:instrument_id]
        @next_questions = instrument.next_questions
      end

    end
  end
end
