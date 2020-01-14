# frozen_string_literal: true

module Api
  module V2
    class QuestionSetQuestionsController < ApiApplicationController
      respond_to :json
      before_action :set_question_set
      before_action :set_question, only: %i[update destroy copy]

      def index
        respond_with @question_set.questions
      end

      def show
        @question = @question_set.questions.find(params[:id])
      end

      def create
        if (resource = Question.only_deleted.find_by(question_identifier: params[:question_set_question][:question_identifier]))
          resource.update(deleted_at: nil, question_set_id: params[:question_set_question][:question_set_id])
          redirect_to action: 'update', id: resource.id
        else
          question = @question_set.questions.new(question_params)
          if question.save
            render json: question, status: :created
          else
            render json: { errors: question.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end

      def update
        respond_with @question.update_attributes(question_params)
      end

      def destroy
        respond_with @question.destroy
      end

      def copy
        new_copy = @question.copy
        if new_copy
          respond_with new_copy
        else
          render json: :nothing, status: :unprocessable_entity
        end
      end

      private

      def set_question_set
        @question_set = QuestionSet.find(params[:question_set_id])
      end

      def set_question
        @question = @question_set.questions.find(params[:id])
      end

      def question_params
        params.require(:question_set_question).permit(:option_set_id, :question_set_id,
                                                      :text, :question_type, :question_identifier, :parent_identifier, :identifies_survey,
                                                      :instruction_id, :critical, :special_option_set_id, :folder_id, :validation_id, :rank_responses)
      end
    end
  end
end
