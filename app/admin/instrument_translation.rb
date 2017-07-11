ActiveAdmin.register InstrumentTranslation do
  belongs_to :instrument
  permit_params :title, :language, :alignment, :instrument_id
  actions :all, except: :new

  controller do
    defaults collection_name: 'translations'
  end
end
