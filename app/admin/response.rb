ActiveAdmin.register Response do
  belongs_to :survey
  permit_params :question_id, :text, :other_response, :special_response, :survey_uuid, :time_started, :time_ended, :question_identifier, :uuid, :device_user_id, :question_version
  config.sort_order = 'id_desc'
  sidebar :versionate, partial: 'layouts/version', only: :show

  index do
    selectable_column
    column :id do |response|
      link_to response.id, admin_survey_response_path(params[:survey_id], response.id)
    end
    column :uuid
    column 'Survey', sortable: :survey_uuid do |s_uuid|
      survey = Survey.find_by_uuid(s_uuid.survey_uuid)
      link_to s_uuid.survey_uuid, admin_instrument_survey_path(survey.instrument_id, survey.id)
    end
    column 'Question', sortable: :question_id do |q_id|
      question = Question.find_by_id(q_id.question_id)
      question ? (link_to q_id.question_id, admin_instrument_question_path(question.instrument_id, question.id)) : q_id.question_id
    end
    column :question_identifier
    column :text
    column :special_response
    column :other_response
    column :response_image do |response|
      if response.response_image && response.response_image.picture
        image_tag(response.response_image.picture.url(:medium))
      end
    end
    column :created_at do |response|
      time_ago_in_words(response.created_at) + ' ago'
    end
    actions
  end

  form do |f|
    f.inputs 'Response Details' do
      f.input :text
      f.input :other_response
      f.input :special_response, collection: Settings.special_responses
    end
    f.actions
  end

  controller do
    def show
      @response = Response.includes(versions: :item).find(params[:id])
      @versions = @response.versions
      @response = @response.versions[params[:version].to_i].reify if params[:version]
      show! # it seems to need this
     end
  end
end
