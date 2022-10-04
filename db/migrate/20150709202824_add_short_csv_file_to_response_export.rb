class AddShortCsvFileToResponseExport < ActiveRecord::Migration[4.2]
  def change
    add_column :response_exports, :short_format_url, :string
    add_column :response_exports, :short_done, :boolean, default: false
  end
end
