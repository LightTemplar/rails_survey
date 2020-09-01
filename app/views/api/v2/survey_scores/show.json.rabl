# frozen_string_literal: true

object @survey_score

attributes :id, :uuid, :survey_id, :score_scheme_id, :score_sum, :identifier

node :instrument_id do |ss|
  ss.survey.instrument_id
end

child :domains do
  attributes :id, :title, :score_scheme_id, :name, :weight
end

child :domain_scores do
  attributes :id, :domain_id, :survey_score_id, :score_sum
end

child :subdomains do
  attributes :id, :title, :domain_id, :name, :weight
end

child :subdomain_scores do
  attributes :id, :subdomain_id, :survey_score_id, :score_sum
end

child :raw_scores do
  attributes :id, :score_unit_id, :survey_score_id, :value

  node :title do |rs|
    rs&.score_unit&.title
  end

  node :weight do |rs|
    rs&.score_unit&.weight
  end

  node :subdomain_id do |rs|
    rs&.subdomain&.id
  end
end
