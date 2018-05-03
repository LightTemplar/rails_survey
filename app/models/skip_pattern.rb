# == Schema Information
#
# Table name: skip_patterns
#
#  id                       :integer          not null, primary key
#  option_identifier        :string
#  question_identifier      :string
#  next_question_identifier :string
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class SkipPattern < ActiveRecord::Base
  belongs_to :option, foreign_key: :option_identifier
  belongs_to :question, foreign_key: :question_identifier
  
  validates :option_identifier, presence: true
  validates :question_identifier, presence: true
  validates :next_question_identifier, presence: true
  validates :question_identifier, uniqueness: { scope: [:option_identifier, :next_question_identifier] }
end
