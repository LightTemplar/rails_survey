# frozen_string_literal: true

class AddPositionToDisplay < ActiveRecord::Migration[5.1]
  def change
    add_column :displays, :instrument_position, :integer
    add_column :instrument_questions, :position, :integer
    add_column :folders, :position, :integer
    add_column :questions, :position, :integer
  end
end
