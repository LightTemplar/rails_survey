# == Schema Information
#
# Table name: option_scores
#
#  id            :integer          not null, primary key
#  score_unit_id :integer
#  option_id     :integer
#  value         :float
#  created_at    :datetime
#  updated_at    :datetime
#  label         :string(255)
#

class OptionScore < ActiveRecord::Base
  belongs_to :option
  belongs_to :score_unit

  # if self belongs_to option, return option.text
  def label
    option ? option.text : read_attribute(:label)
  end

  def as_json(options = {})
    super((options || {}).merge(methods: [:label]))
  end
end
