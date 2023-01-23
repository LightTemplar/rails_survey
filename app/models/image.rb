# frozen_string_literal: true

# == Schema Information
#
# Table name: images
#
#  id          :integer          not null, primary key
#  created_at  :datetime
#  updated_at  :datetime
#  question_id :integer
#  description :string
#  number      :integer
#  deleted_at  :datetime
#

class Image < ApplicationRecord
  belongs_to :question, counter_cache: true
  has_one_attached :photo
  before_save :touch_question
  acts_as_paranoid
  validates :question_id, presence: true, allow_blank: false
  validates :photo, attached: true, content_type: ['image/png', 'image/jpg', 'image/jpeg']

  def photo_url
    photo.url(:medium)
  end

  def touch_question
    question.touch if question && changed?
  end
end
