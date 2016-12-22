ActiveAdmin.register Roster do
  belongs_to :instrument
  sidebar 'Roster Associations', only: :show do
    li link_to 'Surveys', admin_instrument_surveys_path(instrument.id)
  end
end