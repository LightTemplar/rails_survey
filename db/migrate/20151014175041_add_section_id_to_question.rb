class AddSectionIdToQuestion < ActiveRecord::Migration[4.2]
  def change
    add_column :questions, :section_id, :integer
    remove_column :sections, :start_question_identifier
  end
end
