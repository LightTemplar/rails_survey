# frozen_string_literal: true

module Api
  module V2
    class ProjectsController < Api::V2::ApiController
      respond_to :json

      def index
        @projects = current_device_user.projects.includes(:instruments).where(instruments: { published: true })
      end

      def surveys
        @projects = current_device_user.projects.includes(:instruments, surveys: [:responses]).where(
          instruments: { published: true }, surveys: { device_user_id: current_device_user.id, completed: false }
        )
      end
    end
  end
end
