require 'google/cloud/translate'

module GoogleTranslatable
  extend ActiveSupport::Concern

  def translation_client
    project_id = ENV['PROJECT_ID']
    Google::Cloud::Translate.new project: project_id
  end

  def sanitize_text(text)
    Sanitize.fragment(text)
  end
end
