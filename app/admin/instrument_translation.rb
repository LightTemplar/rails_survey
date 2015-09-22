ActiveAdmin.register InstrumentTranslation do
  belongs_to :instrument
  permit_params :title, :language, :alignment, :instrument_id

  controller do
    defaults :collection_name => "translations"
  end
end