class CreateRosters < ActiveRecord::Migration[4.2]
  def change
    create_table :rosters do |t|
      t.integer :project_id
      t.string :uuid
      t.integer :instrument_id
      t.string :identifier
      t.string :instrument_title
      t.integer :instrument_version_number
      t.timestamps
    end
    add_column :surveys, :roster_uuid, :string
  end
end
