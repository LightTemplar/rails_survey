module LanguageAssignable
  extend ActiveSupport::Concern

  included do
    validates :language, presence: true, allow_blank: false
    validates_format_of :language, with: /\A[a-z]{2}|[a-z]{2}-[A-Z]{2}\z/,
                                   message: 'not valid lower-case ISO-639-1 code OR not valid lower-case ISO-639-1 code + upper-case ISO-3166-1 alpha-2 code'
  end
end
