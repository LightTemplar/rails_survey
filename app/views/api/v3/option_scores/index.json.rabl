# frozen_string_literal: true

collection @option_scores
cache ['v3-option-scores', @option_scores]

attributes :id, :score_unit_id, :option_id, :value, :label, :exists,
           :next_question, :deleted_at

node :label, &:label
