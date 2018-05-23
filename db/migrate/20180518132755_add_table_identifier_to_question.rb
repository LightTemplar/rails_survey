class AddTableIdentifierToQuestion < ActiveRecord::Migration
  def change
    add_column :instrument_questions, :table_identifier, :string
    create_table :folders do |t|
      t.integer :question_set_id
      t.string :title
      t.timestamps null: false
    end
    add_column :questions, :folder_id, :integer
    add_column :displays, :section_title, :string
  end
end
