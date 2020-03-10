# frozen_string_literal: true

collection @option_in_option_sets
cache ['v3-option-in-option-sets', @option_in_option_sets]

attributes :id, :option_id, :option_set_id, :deleted_at, :number_in_question,
           :special, :is_exclusive
