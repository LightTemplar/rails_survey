module Api
  module V1
    module Frontend
      class QuestionsController < ApiApplicationController
        respond_to :json

        def index
          instrument = current_project.instruments.find(params[:instrument_id])
          if !params[:page].blank?
            per_page = Settings.questions_per_page
            questions = instrument.questions.page(params[:page]).per(per_page)
            respond_with questions.as_json(include: [:options, :option_skips], methods: [:project_id])
          elsif !params[:grid_id].blank?
            respond_with instrument.questions.where(grid_id: params[:grid_id])
          else
            # TODO: select and return only the attributes that are needed
            respond_with instrument.questions
          end
        end

        def show
          question = current_project.questions.find(params[:id])
          respond_with question
        end

        def create
          instrument = current_project.instruments.find(params[:instrument_id])
          question = instrument.questions.new(question_params)
          if question.save
            ReorderQuestionsWorker.perform_async(instrument.id, instrument.questions.last.number_in_instrument, question.number_in_instrument)
            render json: question, status: :created
          else
            render json: { errors: question.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def update
          instrument = current_project.instruments.find(params[:instrument_id])
          question = instrument.questions.find(params[:id])
          old_number = question.number_in_instrument
          question.update_attributes(question_params)
          if old_number != question.number_in_instrument
            ReorderQuestionsWorker.perform_async(instrument.id, old_number, question.number_in_instrument)
          end
          respond_with question
        end

        def destroy
          instrument = current_project.instruments.find(params[:instrument_id])
          question = instrument.questions.find(params[:id])
          question_number = question.number_in_instrument
          if question.destroy
            DeleteQuestionWorker.perform_async(instrument.id, question_number)
            render nothing: true, status: :ok
          else
            render json: { errors: question.errors.full_messages }, status: :unprocessable_entity
          end
        end

        def copy
          if params[:copy_to]
            instrument = Instrument.find(params[:copy_to])
            question = Question.find(params[:id])
            copy_question = question.amoeba_dup
            copy_question.instrument_id = instrument.id
            copy_question.number_in_instrument = params[:q_position]
            copy_question.question_identifier = params[:q_id]
            if copy_question.save
              if question.images
                question.images.each do |img|
                  copy_image = Image.new
                  copy_image.photo = img.photo
                  copy_image.question_id = copy_question.id
                  copy_image.save
                end
              end
              if question.translations
                create_instrument_translations(question, instrument)
              end
              render json: copy_question, status: :accepted
            end
          end
        end

        private

        def create_instrument_translations(question, instrument)
          question.translations.each do |translation|
            if instrument.translations
              existing_translation = instrument.translations.find_by_language(translation.language)
              instrument.translations.create(language: translation.language) unless existing_translation
            else
              instrument.translations.create(language: translation.language)
            end
          end
        end

        def question_params
          params.require(:question).permit(:text, :question_type, :question_identifier, :instrument_id, :follow_up_position,
                                           :following_up_question_identifier, :reg_ex_validation, :child_update_count, :number_in_instrument, :reg_ex_validation_message, :identifies_survey, :grid_id,
                                           :instructions, :first_in_grid, :instrument_version_number, :critical)
        end
      end
    end
  end
end
