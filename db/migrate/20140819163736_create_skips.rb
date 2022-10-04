class CreateSkips < ActiveRecord::Migration[4.2]
  def change
    create_table :skips do |t|
      t.integer :option_id
      t.string :question_identifier
      t.timestamps
    end
  end
end
