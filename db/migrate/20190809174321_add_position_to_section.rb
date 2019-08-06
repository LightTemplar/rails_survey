# frozen_string_literal: true

class AddPositionToSection < ActiveRecord::Migration
  def change
    add_column :sections, :position, :integer
    add_index :sections, %i[instrument_id title]
    add_index :instruments, %i[project_id title]
  end
end
