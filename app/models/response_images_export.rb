# frozen_string_literal: true

# == Schema Information
#
# Table name: response_images_exports
#
#  id                 :integer          not null, primary key
#  response_export_id :integer
#  download_url       :string
#  done               :boolean          default(FALSE)
#  created_at         :datetime
#  updated_at         :datetime
#

class ResponseImagesExport < ApplicationRecord
  belongs_to :response_export
  before_destroy :destroy_files

  private

  def destroy_files
    if download_url
      File.delete(download_url) if File.exist?(download_url)
    end
  end
end
