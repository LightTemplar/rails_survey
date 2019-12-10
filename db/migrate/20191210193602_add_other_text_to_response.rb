# frozen_string_literal: true

class AddOtherTextToResponse < ActiveRecord::Migration[5.1]
  def change
    add_column :responses, :other_text, :text
    add_column :questions, :instruction_after_text, :boolean, default: false
  end
end
