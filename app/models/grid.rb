# == Schema Information
#
# Table name: grids
#
#  id            :integer          not null, primary key
#  instrument_id :integer
#  question_type :string
#  name          :string
#  created_at    :datetime
#  updated_at    :datetime
#  instructions  :text
#  deleted_at    :datetime
#

class Grid < ActiveRecord::Base
  belongs_to :instrument
  has_many :questions, dependent: :destroy
  has_many :grid_labels, dependent: :destroy
  has_many :grid_translations, dependent: :destroy
  after_save :update_question_types, if: proc { |grid| grid.question_type_changed? }
  acts_as_paranoid

  def update_question_types
    questions.each do |question|
      question.update_attribute(:question_type, question_type)
    end
  end

  def select_one_variant?
    %w[SELECT_ONE SELECT_ONE_WRITE_OTHER].include? question_type
  end

  def select_multiple_variant?
    %w[SELECT_MULTIPLE SELECT_MULTIPLE_WRITE_OTHER].include? question_type
  end

  def list_of_boxes_variant?
    %(LIST_OF_TEXT_BOXES LIST_OF_INTEGER_BOXES).include? question_type
  end
end
