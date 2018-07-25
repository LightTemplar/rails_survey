object @validation
cache @validation

attributes :id, :title, :response_identifier, :validation_type, :validation_message, :relational_operator

node :validation_text do |v|
  if v.validation_type && v.validation_text && v.validation_type == 'SUM_OF_PARTS'
    v.validation_text.to_f
  else
    v.validation_text
  end
end