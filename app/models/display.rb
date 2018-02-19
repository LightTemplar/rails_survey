# == Schema Information
#
# Table name: displays
#
#  id            :integer          not null, primary key
#  mode          :string
#  position      :string
#  instrument_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#  title         :string
#  deleted_at    :datetime
#

class Display < ActiveRecord::Base
  belongs_to :instrument
  has_many :instrument_questions
  before_destroy :unset_instrument_questions
  acts_as_paranoid
  has_paper_trail
  private

  def unset_instrument_questions
    instrument_questions.update_all(display_id: nil)
  end
end
