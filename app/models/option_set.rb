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

  private

  def set_option_specialty
    if special
      options.update_all(special: true)
    else
      options.update_all(special: false)
    end
  end
end
