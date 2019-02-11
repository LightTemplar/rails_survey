# frozen_string_literal: true

ActiveAdmin.register Response do
  belongs_to :survey
  permit_params :question_id, :text, :other_response, :special_response,
                :survey_uuid, :time_started, :time_ended, :question_identifier, :uuid,
                :device_user_id, :question_version
  config.sort_order = 'id_desc'
  config.per_page = [50, 100, 200]
  config.filters = true
  filter :id
  filter :uuid
  filter :text
  filter :question_identifier
  sidebar :versionate, partial: 'layouts/version', only: :show

  index do
    selectable_column
    column :uuid
    column 'Survey', sortable: :survey_uuid do |s_uuid|
      survey = Survey.find_by_uuid(s_uuid.survey_uuid)
    end
    column :question_identifier
    column :text
    column :special_response
    column :other_response
    column :rank_order
    column :response_image do |response|
      image_tag(response.response_image.picture.url(:medium)) if response.response_image&.picture
    end
    column :critical, &:is_critical
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
      show!
    end
  end
end
