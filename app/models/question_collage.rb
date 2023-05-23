# == Schema Information
#
# Table name: question_collages
#
#  id          :bigint           not null, primary key
#  question_id :integer
#  collage_id  :integer
#  position    :integer
#  deleted_at  :datetime
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#
class QuestionCollage < ApplicationRecord
  belongs_to :question, inverse_of: :question_collages
  belongs_to :collage, inverse_of: :question_collages
  acts_as_paranoid
end
