class RemoveResponseExportFiles < ActiveRecord::Migration[4.2]
  def change
    remove_column :response_exports, :long_format_url
    remove_column :response_exports, :short_format_url
    remove_column :response_exports, :wide_format_url
    add_column :instruments, :auto_export_responses, :boolean, default: true
  end
end
