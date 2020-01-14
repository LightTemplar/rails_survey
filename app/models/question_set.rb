# frozen_string_literal: true

# == Schema Information
#
# Table name: question_sets
#
#  id         :integer          not null, primary key
#  title      :string
#  created_at :datetime
#  updated_at :datetime
#

class QuestionSet < ApplicationRecord
  has_many :questions, dependent: :destroy
  has_many :translations, through: :questions
  has_many :folders, -> { order 'position' }, dependent: :destroy

  validates :title, presence: true, allow_blank: false, uniqueness: true

  def order_folders(order)
    ActiveRecord::Base.transaction do
      order.each_with_index do |value, index|
        folder = folders.where(id: value).first
        folder.update_columns(position: index + 1) if folder && folder.position != index + 1
      end
    end
  end
end
