# frozen_string_literal: true

collection @option_sets

attributes :id, :deleted_at, :title, :special, :instruction_id, :align_image_vertical

node :has_images, &:has_images?

child :option_set_translations do |_t|
  attributes :id, :option_set_id, :option_translation_id

  node :option_id do |t|
    t.option&.id
  end

  node :language, &:language
end
