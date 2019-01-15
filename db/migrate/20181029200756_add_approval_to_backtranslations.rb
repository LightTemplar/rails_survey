class AddApprovalToBacktranslations < ActiveRecord::Migration
  def change
    add_column :back_translations, :approved, :boolean
  end
end
