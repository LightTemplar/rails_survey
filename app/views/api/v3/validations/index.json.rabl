collection @validations
cache ['v3-validations', @validations]

attributes :id, :validation_identifier, :validation_text, :validation_message, :response_operators, :validation_type,
:title, :deleted_at

child :translations do
  attributes :id, :validation_id, :text, :language
end
