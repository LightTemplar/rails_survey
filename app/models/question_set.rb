# == Schema Information
#
# Table name: question_sets
#
#  id         :integer          not null, primary key
#  title      :string
#  created_at :datetime
#  updated_at :datetime
#

class QuestionSet < ActiveRecord::Base
  has_many :questions, dependent: :destroy
  has_many :translations, through: :questions
  has_many :folders
end
