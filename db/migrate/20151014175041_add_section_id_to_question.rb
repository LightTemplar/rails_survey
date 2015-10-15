class AddSectionIdToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :section_id, :integer
    remove_column :sections, :start_question_identifier
  end
end
