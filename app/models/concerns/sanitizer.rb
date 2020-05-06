# frozen_string_literal: true

module Sanitizer
  extend ActiveSupport::Concern

  def full_sanitizer
    Rails::Html::FullSanitizer.new
  end

  def safe_list_sanitizer
    Rails::Html::SafeListSanitizer.new
  end
end
