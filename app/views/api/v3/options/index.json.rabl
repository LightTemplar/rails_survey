# frozen_string_literal: true

collection @options

attributes :id, :identifier, :text, :deleted_at

child :translations do
  attributes :id, :option_id, :text, :language
end
