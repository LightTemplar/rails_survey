# frozen_string_literal: true

class AddPopUpToQuestion < ActiveRecord::Migration[5.1]
  def change
    remove_column :questions, :pop_up_instruction
    add_column :questions, :pop_up_instruction_id, :integer
  end
end
