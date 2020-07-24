# frozen_string_literal: true

module Api
  module V2
    class SectionsController < Api::V2::ApiController
      respond_to :json

      def index
        project = current_device_user.projects.find(params[:project_id])
        instrument = project.instruments.find(params[:instrument_id])
        @sections = instrument.sections.includes(:displays)
      end
    end
  end
end
