# == Schema Information
#
# Table name: question_translations
#
#  id                        :integer          not null, primary key
#  question_id               :integer
#  language                  :string(255)
#  text                      :text
#  created_at                :datetime
#  updated_at                :datetime
#  reg_ex_validation_message :string(255)
#  question_changed          :boolean          default(FALSE)
#  instructions              :text
#

class QuestionTranslation < ActiveRecord::Base
  belongs_to :question
  before_save :touch_question
  validates :text, presence: true, allow_blank: false

  def touch_question
    question.touch if question && changed?
  end
end
