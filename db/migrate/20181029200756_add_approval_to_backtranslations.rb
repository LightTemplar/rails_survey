class AddApprovalToBacktranslations < ActiveRecord::Migration[4.2]
  def change
    add_column :back_translations, :approved, :boolean
  end
end
