# frozen_string_literal: true

module Sanitizable
  extend ActiveSupport::Concern
  include Sanitizer

  included do
    before_save :sanitize_text
  end

  def safe_sanitize(str)
    safe_list_sanitizer.sanitize(str, tags: safe_tags)
  end

  def full_sanitize(str)
    full_sanitizer.sanitize(str)
  end

  def html_decode(str)
    HTMLEntities.new.decode(str)
  end

  private

  def safe_tags
    %w[p strong em i b u li ul a h1 h2 h3 h4 h5 h6 strikethrough sub sup]
  end

  def sanitize_text
    self.text = safe_list_sanitizer.sanitize(text, tags: safe_tags).gsub(%r{<p>[\s$]*</p>}, '') if attribute_present?('text')
  end
end
