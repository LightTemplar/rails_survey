# == Schema Information
#
# Table name: instrument_questions
#
#  id                   :integer          not null, primary key
#  question_id          :integer
#  instrument_id        :integer
#  number_in_instrument :integer
#  display_id           :integer
#  created_at           :datetime
#  updated_at           :datetime
#

class InstrumentQuestion < ActiveRecord::Base
  belongs_to :instrument, touch: true
  belongs_to :question
  belongs_to :display, touch: true
  has_many :next_questions
  has_many :multiple_skips
  has_many :translations, through: :question
end
