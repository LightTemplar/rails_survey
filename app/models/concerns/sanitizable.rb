# frozen_string_literal: true

module Sanitizable
  extend ActiveSupport::Concern

  included do
    before_save :sanitize_text
  end

  private

  def sanitize_text
    sanitizer = Rails::Html::SafeListSanitizer.new
    self.text = sanitizer.sanitize(text, tags: %w[p strong em i b u li ul a h1 h2 h3 h4 h5 h6]).gsub(%r{<p>[\s$]*</p>}, '') if attribute_present?('text')
  end
end
