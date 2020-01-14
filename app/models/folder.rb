# frozen_string_literal: true

# == Schema Information
#
# Table name: folders
#
#  id              :integer          not null, primary key
#  question_set_id :integer
#  title           :string
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  position        :integer
#

class Folder < ApplicationRecord
  belongs_to :question_set, touch: true
  has_many :questions, -> { order 'position' }

  def order_questions(order)
    ActiveRecord::Base.transaction do
      order.each_with_index do |value, index|
        question = questions.where(id: value).first
        question.update_columns(position: index + 1) if question && question.position != index + 1
      end
    end
  end
end
