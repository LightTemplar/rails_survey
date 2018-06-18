module Api
  module V2
    class QuestionSetsController < ApiApplicationController
      respond_to :json

      def index
        respond_with QuestionSet.all.order(:created_at)
      end

      def show
        respond_with QuestionSet.find(params[:id])
      end

      def create
        question_set = QuestionSet.new(question_set_params)
        if question_set.save
          render json: question_set, status: :created
        else
          render json: { errors: question_set.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def update
        question_set = QuestionSet.find(params[:id])
        respond_with question_set.update_attributes(question_set_params)
      end

      def destroy
        qs = QuestionSet.find(params[:id])
        respond_with qs.destroy
      end

      private

      def question_set_params
        params.require(:question_set).permit(:title)
      end
    end
  end
end
