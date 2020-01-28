# frozen_string_literal: true

class AddAfterTextInstruction < ActiveRecord::Migration[5.1]
  def change
    add_column :questions, :after_text_instruction_id, :integer
    Question.all.each do |question|
      next unless question.instruction_after_text

      question.after_text_instruction_id = question.instruction_id
      question.instruction_id = nil
      question.save
    end
    remove_column :questions, :instruction_after_text
  end
end
