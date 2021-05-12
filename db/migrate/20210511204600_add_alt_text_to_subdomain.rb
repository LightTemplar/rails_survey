class AddAltTextToSubdomain < ActiveRecord::Migration[5.2]
  def change
    add_column :subdomains, :alt_text, :string
  end
end
