# frozen_string_literal: true

object @domain

attributes :id, :title, :score_scheme_id

child :subdomains do
  attributes :id, :title, :domain_id
end
