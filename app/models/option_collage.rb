# == Schema Information
#
# Table name: option_collages
#
#  id                      :bigint           not null, primary key
#  option_in_option_set_id :integer
#  collage_id              :integer
#  position                :integer
#  deleted_at              :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#
class OptionCollage < ApplicationRecord
  belongs_to :option_in_option_set
  belongs_to :collage
  acts_as_paranoid
end
