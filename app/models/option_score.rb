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
#

class OptionScore < ActiveRecord::Base
  belongs_to :option
  belongs_to :score_unit

  def label
    option.text
  end

  def as_json(options={})
    super((options || {}).merge({ methods: [:label] }))
  end

end