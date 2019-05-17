# frozen_string_literal: true

collection @critical_responses
cache ['v3-critical-responses', @critical_responses]

attributes :id, :question_identifier, :option_identifier, :instruction_id, :deleted_at
