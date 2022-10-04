class AddSectionChangedToSectionTranslation < ActiveRecord::Migration[4.2]
  def change
    add_column :section_translations, :section_changed, :boolean, default: false
  end
end
