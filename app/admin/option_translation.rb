ActiveAdmin.register OptionTranslation do
  belongs_to :option
  permit_params :text, :language, :option_id
  config.per_page = 20

  controller do
    defaults :collection_name => "translations"
  end
end
