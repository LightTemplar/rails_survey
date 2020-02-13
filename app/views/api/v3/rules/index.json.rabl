# frozen_string_literal: true

collection @instrument_rules

attributes :id, :instrument_id, :deleted_at

node :rule_type do |ir|
  ir.rule&.rule_type
end

node :rule_params do |ir|
  ir.rule&.rule_params
end
