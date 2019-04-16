# frozen_string_literal: true

collection @option_sets
cache ['v3-option-sets', @option_sets]

attributes :id, :deleted_at, :title, :special

node :instructions do |os|
  os.instruction&.text
end

child :option_set_translations do |_t|
  attributes :id, :option_set_id, :option_translation_id

  node :option_id do |t|
    t.option.id
  end

  node :language, &:language
end
