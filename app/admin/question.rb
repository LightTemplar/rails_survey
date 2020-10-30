# frozen_string_literal: true

ActiveAdmin.register Question do
  belongs_to :project
  actions :all, except: %i[new edit destroy]
  config.per_page = [50, 100, 250, 500]
  config.sort_order = 'id_asc'
  config.filters = false

  index do
    column :id
    column :question_identifier
    column :text do |question|
      strip_tags question.text
    end
    column 'Response Count' do |question|
      question.responses.size
    end
    actions
  end

  show do
    attributes_table do
      row :id
      row :text do |question|
        strip_tags question.text
      end
      row :question_type
      row :question_identifier
      row :identifies_survey
      row :question_set_id
      row :option_set_id
      row :instruction_id
      row :special_option_set_id
      row :parent_identifier
      row :folder_id
      row :validation_id
      row :rank_responses
      row :created_at
      row :updated_at
      row :deleted_at
    end

    h3 'Response Summary Statistics'
    table_for question.responses.group(:text).count.each do
      column('Response') { |response, _count| response }
      column('Count') { |_response, count| count }
      column('Percentage') { |_response, count| (count / question.responses.size.to_f * 100.0).round(3) }
    end

    h3 'Responses to question'
    table_for question.responses do
      column :id
      column :uuid
      column 'Q ID', :question_id
      column 'Identifier', :question_identifier
      column :survey_uuid
      column 'Q Version', :question_version
      column :text
      column 'Entry', :other_text
      column 'Other', :other_response
      column 'Special', :special_response do |question|
        strip_tags question.special_response
      end
      column :time_started
      column :time_ended
      column :created_at
      column :updated_at
    end
  end
end
