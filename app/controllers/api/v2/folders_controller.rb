module Api
  module V2
    class FoldersController < ApiApplicationController
      respond_to :json
      before_action :set_question_set

      def index
        respond_with @question_set.folders
      end

      def create
        folder = @question_set.folders.new(folder_params)
        if folder.save
          render json: folder, status: :created
        else
          render json: {errors: folder.errors.full_messages}, status: :unprocessable_entity
        end
      end

      def update
        folder = @question_set.folders.find(params[:id])
        respond_with folder.update_attributes(folder_params)
      end

      def destroy
        folder = @question_set.folders.find(params[:id])
        if folder.destroy
          render nothing: true, status: :ok
        else
          render json: { errors: folder.errors.full_messages }, status: :unprocessable_entity
        end
      end

      private

      def set_question_set
        @question_set = QuestionSet.find(params[:question_set_id])
      end

      def folder_params
        params.require(:folder).permit(:question_set_id, :title)
      end
    end
  end
end
