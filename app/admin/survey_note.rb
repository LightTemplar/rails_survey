ActiveAdmin.register SurveyNote do
  belongs_to :survey
  permit_params :survey_uuid, :device_user_id, :reference, :text

  form do |f|
    f.inputs 'Survey Note Details' do
      f.input :survey_uuid
      f.input :device_user_id, as: :select, collection: survey.project.device_users
      f.input :reference
      f.input :text
    end
    f.actions
  end
end
