object @instrument_rule
cache @instrument_rule

attributes :id, :instrument_id, :rule_id

node :rule_type do |ir|
  ir.rule.rule_type if ir.rule
end

node :rule_params do |ir|
  ir.rule.rule_params if ir.rule
end
