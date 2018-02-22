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
#  identifier           :string
#  deleted_at           :datetime
#

class InstrumentQuestion < ActiveRecord::Base
  belongs_to :instrument, touch: true
  belongs_to :question
  belongs_to :display, touch: true
  has_many :next_questions
  has_many :multiple_skips
  has_many :follow_up_questions
  has_many :translations, through: :question
  acts_as_paranoid
  has_paper_trail
  validates :identifier, presence: true
  validates :identifier, uniqueness: { scope: :instrument_id,
    message: 'instrument already has this identifier' }
end
