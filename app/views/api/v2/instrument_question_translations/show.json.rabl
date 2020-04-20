# frozen_string_literal: true

object @instrument_question_translation
cache @instrument_question_translation

attributes :id, :instrument_id, :question_id, :number_in_instrument, :display_id, :identifier

node :type do |iq|
  iq.question&.question_type
end

node :text do |iq|
  iq.question&.text
end

node :question_set_id do |iq|
  iq.question&.question_set_id
end

node :option_set_id do |iq|
  iq.question&.option_set_id
end

node :special_option_set_id do |iq|
  iq.question&.special_option_set_id
end

child :translations do
  attributes :id, :question_id, :text, :language
end

child :back_translations do
  attributes :id, :approved, :text, :language, :backtranslatable_id, :backtranslatable_type
end

child :non_special_options do
  attributes :id, :identifier, :text
end

child :option_translations do
  attributes :id, :option_id, :text, :language
end

child option_back_translations: :option_back_translations do
  attributes :id, :approved, :text, :language, :backtranslatable_id, :backtranslatable_type
end
