# == Schema Information
#
# Table name: images
#
#  id                 :integer          not null, primary key
#  created_at         :datetime
#  updated_at         :datetime
#  photo_file_name    :string(255)
#  photo_content_type :string(255)
#  photo_file_size    :integer
#  photo_updated_at   :datetime
#  question_id        :integer
#  description        :string(255)
#  number             :integer
#  deleted_at         :datetime
#

class Image < ActiveRecord::Base
  belongs_to :question
  has_attached_file :photo, styles: { small: '200x200>', medium: '300x300>' }, url: '/:attachment/:id/:basename.:extension', path: 'files/:attachment/:id/:style/:basename.:extension'
  before_save :touch_question
  acts_as_paranoid
  validates_attachment_content_type :photo, content_type: %r{\Aimage\/.*\Z}
  validates_attachment_file_name :photo, matches: [/png\Z/, /jpe?g\Z/]
  validates_with AttachmentSizeValidator, attributes: :photo, less_than: 1.megabytes
  validates :question_id, presence: true, allow_blank: false

  def photo_url
    photo.url(:medium)
  end

  def touch_question
    question.touch if question && changed?
  end
end
