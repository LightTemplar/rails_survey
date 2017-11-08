# == Schema Information
#
# Table name: instrument_questions
#
#  id                   :integer          not null, primary key
#  question_id          :integer
#  instrument_id        :integer
#  number_in_instrument :integer
#  display_type         :string
#  created_at           :datetime
#  updated_at           :datetime
#

class InstrumentQuestion < ActiveRecord::Base
  belongs_to :instrument
  belongs_to :question
  has_many :next_questions
end
