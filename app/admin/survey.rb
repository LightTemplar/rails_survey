ActiveAdmin.register Survey do
  belongs_to :instrument
  sidebar 'Survey Associations', only: :show do
    ul do
      li link_to 'Responses', admin_survey_responses_path(params[:id])
    end
  end

  permit_params :instrument_id, :instrument_version_number, :uuid, :device_id, :instrument_title,
                :device_uuid, :latitude, :longitude, :metadata, :completion_rate

  config.sort_order = 'id_desc'
  config.filters = true
  filter :id
  filter :uuid
  filter :device_label
  filter :metadata
  actions :all, except: :new

  index do
    selectable_column
    column :id do |survey|
      link_to survey.id, admin_instrument_survey_path(survey.instrument_id, survey.id)
    end
    column :uuid
    column 'Instrument', sortable: :instrument_title do |survey|
      instrument = Instrument.find_by_id(survey.instrument_id)
      instrument ? (link_to survey.instrument_title, admin_project_instrument_path(instrument.project_id, survey.instrument_id)) : survey.instrument_title
    end
    column 'Instrument Versions', sortable: :instrument_version_number do |version|
      version.instrument_version_number
    end
    column :created_at do |survey|
      time_ago_in_words(survey.created_at) + ' ago'
    end
    column :completion_rate
    actions
  end

  form do |f|
    f.inputs 'Survey Details' do
      f.input :metadata
    end
    f.actions
  end

end