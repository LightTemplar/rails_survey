module Sanitizable
  extend ActiveSupport::Concern

  def sanitize(str)
    ActionView::Base.full_sanitizer.sanitize(str)
  end
end
