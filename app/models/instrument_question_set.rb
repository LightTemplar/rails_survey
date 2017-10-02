# == Schema Information
#
# Table name: instrument_question_sets
#
#  id              :integer          not null, primary key
#  instrument_id   :integer
#  question_set_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#

class InstrumentQuestionSet < ActiveRecord::Base
  belongs_to :instrument
  belongs_to :question_set
end
