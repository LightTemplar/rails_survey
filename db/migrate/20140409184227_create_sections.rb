class CreateSections < ActiveRecord::Migration[4.2]
  def change
    create_table :sections do |t|
      t.string :title
      t.string :start_question_identifier
      t.timestamps
    end
  end
end
