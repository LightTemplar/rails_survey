ActiveAdmin.register Question do
  belongs_to :project
  actions :all, except: [:new, :edit, :destroy]
  config.per_page = [50, 100, 250, 500]
  config.sort_order = 'id_asc'
  index do
    selectable_column
    column :id
    column :question_identifier
    column :text
    column "Response Count" do |question|
      question.responses.size
    end
    actions
  end

  show do
    attributes_table do
      row :id
      row :text
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

    h3 'Responses to question'
    table_for question.responses do
      column :id
      column :uuid
      column :question_id
      column :question_identifier
      column :survey_uuid
      column :question_version
      column :text
      column :other_response
      column :special_response
      column :time_started
      column :time_ended
      column :created_at
      column :updated_at
    end
  end

  sidebar 'Summary Statistics', only: :show do
    render partial: 'summary', :locals => {
      :responses => question.responses.group(:text).count,
      :total => question.responses.size }
  end
end
