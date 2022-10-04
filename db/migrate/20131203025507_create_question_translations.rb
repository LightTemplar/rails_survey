class CreateQuestionTranslations < ActiveRecord::Migration[4.2]
  def change
    create_table :question_translations do |t|
      t.integer :question_id
      t.string :language
      t.string :text

      t.timestamps
    end
  end
end
