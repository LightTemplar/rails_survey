# frozen_string_literal: true

module FullSanitizer
  extend ActiveSupport::Concern

  def full_sanitizer
    Rails::Html::FullSanitizer.new
  end
end
