# frozen_string_literal: true

collection @survey_scores

attributes :id, :uuid, :survey_id, :score_scheme_id, :score_sum, :identifier

node :instrument_title, &:instrument_title
node :instrument_id, &:instrument_id
