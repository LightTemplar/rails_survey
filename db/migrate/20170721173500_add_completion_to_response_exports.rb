class AddCompletionToResponseExports < ActiveRecord::Migration[4.2]
  def change
    add_column :response_exports, :completion, :decimal, precision: 5, scale: 2, default: 0.0
  end
end
