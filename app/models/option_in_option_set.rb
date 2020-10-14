# frozen_string_literal: true

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
#  special            :boolean          default(FALSE)
#  instruction_id     :integer
#  allow_text_entry   :boolean          default(FALSE)
#  exclusion_ids      :text
#

class OptionInOptionSet < ApplicationRecord
  default_scope { order('option_in_option_sets.special ASC, option_in_option_sets.number_in_question ASC') }
  belongs_to :option
  belongs_to :option_set, touch: true, counter_cache: true
  belongs_to :instruction

  after_save :set_special

  has_paper_trail
  acts_as_paranoid
  acts_as_list scope: :option_set, column: :number_in_question

  validates :option_id, uniqueness: { scope: [:option_set_id] }

  private

  def set_special
    update_columns(special: true) if option_set.special
  end
end
