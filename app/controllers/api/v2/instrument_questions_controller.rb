# frozen_string_literal: true

module Api
  module V2
    class InstrumentQuestionsController < Api::V2::ApiController
      respond_to :json

      def index
        project = current_device_user.projects.find(params[:project_id])
        instrument = project.instruments.find(params[:instrument_id])
        display = instrument.displays.find(params[:display_id])
        @instrument_questions = display.instrument_questions.includes(
          question: [:instruction, :after_text_instruction, :pop_up_instruction,
                     option_set: [:instruction, option_in_option_sets: %i[option instruction]],
                     special_option_set: [:instruction, option_in_option_sets: %i[option instruction]]]
        )
      end
    end
  end
end
