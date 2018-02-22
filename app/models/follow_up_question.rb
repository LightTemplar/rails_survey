# == Schema Information
#
# Table name: follow_up_questions
#
#  id                               :integer          not null, primary key
#  question_identifier              :string
#  following_up_question_identifier :string
#  position                         :integer
#  instrument_question_id           :integer
#  deleted_at                       :datetime
#  created_at                       :datetime         not null
#  updated_at                       :datetime         not null
#

class FollowUpQuestion < ActiveRecord::Base
  # belongs_to :option, foreign_key: :option_identifier
  # belongs_to :question, foreign_key: :question_identifier
  belongs_to :instrument_question
  acts_as_paranoid
  validates :following_up_question_identifier, presence: true
  validates :question_identifier, presence: true
  validates :instrument_question_id, presence: true
  validates :position, presence: true, uniqueness: { scope: :instrument_question_id,
    message: 'followup position has already been taken' }
end
