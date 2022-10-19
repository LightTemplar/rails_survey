# == Schema Information
#
# Table name: collages
#
#  id         :bigint           not null, primary key
#  name       :string
#  deleted_at :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Collage < ApplicationRecord
  has_many :diagrams
  has_many :question_collages, dependent: :destroy
  has_many :option_collages, dependent: :destroy
  acts_as_paranoid
end
