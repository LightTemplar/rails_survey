# frozen_string_literal: true

class AddPositionToSection < ActiveRecord::Migration
  def change
    add_column :sections, :position, :integer
    add_index :sections, %i[instrument_id title]
    add_index :instruments, %i[project_id title]
    remove_index :instrument_questions, :identifier
    add_index :instrument_questions, %i[instrument_id identifier]
    remove_column :displays, :mode
  end
end
