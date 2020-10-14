# frozen_string_literal: true

module Api
  module V2
    class SurveyScoresController < Api::V2::ApiController
      respond_to :json

      def index
        @survey_scores = current_device_user.survey_scores
      end

      def show
        @survey_score = current_device_user.survey_scores.includes(:domains,
                                                                   :domain_scores,
                                                                   :subdomains,
                                                                   :subdomain_scores,
                                                                   :raw_scores)
                                           .find(params[:id])
      end
    end
  end
end
