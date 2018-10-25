# == Schema Information
#
# Table name: multiple_skips
#
#  id                       :integer          not null, primary key
#  question_identifier      :string
#  option_identifier        :string
#  skip_question_identifier :string
#  instrument_question_id   :integer
#  deleted_at               :datetime
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class MultipleSkip < ActiveRecord::Base
  belongs_to :option, foreign_key: :option_identifier
  belongs_to :question, foreign_key: :question_identifier
  belongs_to :instrument_question, touch: true
  acts_as_paranoid
  validates :question_identifier, uniqueness: { scope: [:option_identifier, :skip_question_identifier] }
end
