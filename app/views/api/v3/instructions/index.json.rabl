# frozen_string_literal: true

collection @instructions

attributes :id, :text, :deleted_at

child :instruction_translations do |_t|
  attributes :id, :instruction_id, :text, :language
end
