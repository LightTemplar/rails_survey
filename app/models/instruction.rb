# == Schema Information
#
# Table name: instructions
#
#  id         :integer          not null, primary key
#  title      :string
#  text       :text
#  created_at :datetime
#  updated_at :datetime
#  deleted_at :datetime
#

class Instruction < ActiveRecord::Base
  has_many :questions, dependent: :nullify
  has_many :instruments, -> { distinct }, through: :questions
  has_many :instruction_translations, dependent: :destroy
  has_many :display_instructions, dependent: :destroy
  acts_as_paranoid
  has_paper_trail
  after_commit :update_instruments_versions, on: %i[update destroy]

  def update_instruments_versions
    instruments.each(&:touch)
  end

end
