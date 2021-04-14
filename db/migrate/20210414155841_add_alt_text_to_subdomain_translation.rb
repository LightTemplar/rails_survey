class AddAltTextToSubdomainTranslation < ActiveRecord::Migration[5.2]
  def change
    add_column :subdomain_translations, :alt_text, :string
  end
end
