# == Schema Information
#
# Table name: loop_questions
#
#  id                     :integer          not null, primary key
#  instrument_question_id :integer
#  parent                 :string
#  looped                 :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  deleted_at             :datetime
#

class LoopQuestion < ActiveRecord::Base
  belongs_to :instrument_question
  acts_as_paranoid
  validates :instrument_question_id, uniqueness: { scope: [:parent, :looped] }
end
