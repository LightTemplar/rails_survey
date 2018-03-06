# == Schema Information
#
# Table name: option_in_option_sets
#
#  id                 :integer          not null, primary key
#  option_id          :integer          not null
#  option_set_id      :integer          not null
#  number_in_question :integer          not null
#  deleted_at         :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class OptionInOptionSet < ActiveRecord::Base
  belongs_to :option
  belongs_to :option_set
  has_paper_trail
  acts_as_paranoid
end
