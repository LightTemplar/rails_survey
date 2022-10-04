class AddValueLabelsCsvToExports < ActiveRecord::Migration[4.2]
  def change
    add_column :response_exports, :value_labels_csv, :string
  end
end
