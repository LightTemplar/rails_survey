# == Schema Information
#
# Table name: collages
#
#  id          :bigint           not null, primary key
#  question_id :integer
#  name        :string
#  position    :integer
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class Collage < ApplicationRecord
  belongs_to :question
  has_many :diagrams
  acts_as_paranoid
end
