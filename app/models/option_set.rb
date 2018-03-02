# == Schema Information
#
# Table name: option_sets
#
#  id         :integer          not null, primary key
#  title      :string
#  created_at :datetime
#  updated_at :datetime
#  special    :boolean          default(FALSE)
#

class OptionSet < ActiveRecord::Base
  has_many :options, dependent: :destroy
  has_many :questions
  after_save :set_option_specialty

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
      options.update_all(special: true)
    else
      options.update_all(special: false)
    end
  end
end
