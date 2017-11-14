class AddRandomizationOrderToSurvey < ActiveRecord::Migration
  def change
    add_column :surveys, :randomization_order, :text
  end
end
