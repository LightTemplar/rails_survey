class AddSpecialTo < ActiveRecord::Migration
  def change
    remove_column :options, :special, :boolean
    remove_column :options, :question_id, :integer
    remove_column :options, :option_set_id, :integer
    remove_column :options, :number_in_question, :integer
    add_column :option_in_option_sets, :special, :boolean, default: false
  end
end
