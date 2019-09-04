# frozen_string_literal: true

module Api
  module V4
    class QuestionSetsController < Api::V4::ApiController
      respond_to :json
      before_action :set_question_set, only: %i[show update destroy]
      def index
        @question_sets = QuestionSet.all.includes(:folders)
      end

      def show; end

      def create
        question_set = QuestionSet.new(question_set_params)
        if question_set.save
          render json: question_set, status: :created
        else
          render json: { errors: question_set.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        respond_with @question_set.update_attributes(question_set_params)
      end

      def destroy
        respond_with @question_set.destroy
      end

      private

      def question_set_params
        params.require(:question_set).permit(:title)
      end

      def set_question_set
        @question_set = QuestionSet.find(params[:id])
      end
    end
  end
end
