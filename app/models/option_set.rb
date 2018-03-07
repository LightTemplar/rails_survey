# == Schema Information
#
# Table name: option_sets
#
#  id         :integer          not null, primary key
#  title      :string
#  created_at :datetime
#  updated_at :datetime
#  special    :boolean          default(FALSE)
#  deleted_at :datetime
#

class OptionSet < ActiveRecord::Base
  has_many :option_in_option_sets
  has_many :options, through: :option_in_option_sets
  has_many :questions
  after_save :set_option_specialty, if: proc { |option_set| option_set.special_changed? }
  has_paper_trail
  acts_as_paranoid

  def copy
    new_copy = self.dup
    new_copy.title = title + Time.now.to_i.to_s
    new_copy.save!
    options.each do |op|
      new_op = op.dup
      new_op.identifier = op.identifier + Time.now.to_i.to_s
      new_op.option_set_id = new_copy.id
      new_op.save!
      op.translations.each do |ot|
        new_ot = ot.dup
        new_ot.option_id = new_op.id
        new_ot.save!
      end
    end
    new_copy
  end

  private

  def set_option_specialty
    if special
      option_in_option_sets.update_all(special: true)
    else
      option_in_option_sets.update_all(special: false)
    end
  end
end
