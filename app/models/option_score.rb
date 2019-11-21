# == Schema Information
#
# Table name: option_scores
#
#  id                     :integer          not null, primary key
#  score_unit_question_id :integer
#  value                  :float
#  created_at             :datetime
#  updated_at             :datetime
#  deleted_at             :datetime
#  option_identifier      :string
#  follow_up_qid          :string
#  position               :string
#

class OptionScore < ActiveRecord::Base
  belongs_to :option
  belongs_to :score_unit
  acts_as_paranoid

  # if self belongs_to option, return option.text
  def label
    option ? option.text : read_attribute(:label)
  end

end
