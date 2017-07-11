class AddDeletedAtToScoreSchemes < ActiveRecord::Migration
  def change
    add_column :score_schemes, :deleted_at, :datetime
    add_index :score_schemes, :deleted_at
    add_column :score_units, :deleted_at, :datetime
    add_index :score_units, :deleted_at
    add_column :score_unit_questions, :deleted_at, :datetime
    add_index :score_unit_questions, :deleted_at
    add_column :option_scores, :deleted_at, :datetime
    add_index :option_scores, :deleted_at
    add_column :instruments, :scorable, :boolean, default: false
  end
end
