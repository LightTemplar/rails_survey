# frozen_string_literal: true

module Api
  module V2
    class InstrumentQuestionTranslationsController < ApiApplicationController
      respond_to :json

      def index
        project = Project.find params[:project_id]
        instrument = project.instruments.find params[:instrument_id]
        @instrument_question_translations = instrument.instrument_questions
                                                      .includes(:question, :translations, :back_translations)
      end
    end
  end
end
