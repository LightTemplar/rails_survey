class CreateValidations < ActiveRecord::Migration[4.2]
  def change
    create_table :validations do |t|
      t.string :title
      t.string :reg_ex_validation
      t.string :reg_ex_validation_message
      t.datetime :deleted_at

      t.timestamps null: false
    end
    add_column :questions, :validation_id, :integer
    create_table :validation_translations do |t|
      t.integer :validation_id
      t.string :language
      t.string :text

      t.timestamps null: false
    end
  end
end
