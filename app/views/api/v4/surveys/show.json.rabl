# frozen_string_literal: true

object @survey

attributes :id, :instrument_id, :instrument_title, :uuid

node :project_name, &:project_name
node :identifier, &:identifier
