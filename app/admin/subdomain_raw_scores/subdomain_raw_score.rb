# frozen_string_literal: true

ActiveAdmin.register RawScore, as: 'SubdomainRawScore' do
  belongs_to :subdomain
  navigation_menu :subdomain

  config.per_page = [50, 100]

  index do
    selectable_column
    column :id
    column :score_unit
    column :survey_score
    column :value
    column 'Domain', &:domain
    column 'Subdomain', &:subdomain
    column 'Identifier', sortable: :survey_score_id, &:identifier
    actions
  end

  controller do
    defaults collection_name: 'raw_scores'
  end
end
