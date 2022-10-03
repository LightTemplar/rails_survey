# frozen_string_literal: true

collection @options

attributes :id, :identifier, :text, :text_one, :text_two, :deleted_at

child :translations do
  attributes :id, :option_id, :text, :language
end
