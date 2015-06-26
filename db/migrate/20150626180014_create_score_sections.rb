class CreateScoreSections < ActiveRecord::Migration
  def change
    create_table :score_sections do |t|
      t.string :name

      t.timestamps
    end
  end
end
