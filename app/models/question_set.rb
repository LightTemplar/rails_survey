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
  has_many :folders, dependent: :destroy

  validates :title, presence: true, allow_blank: false, uniqueness: true
end
