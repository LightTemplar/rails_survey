# frozen_string_literal: true

ActiveAdmin.register RawScore do
  belongs_to :survey_score
  navigation_menu :survey_score

  index do
    selectable_column
    column :id
    column :score_unit
    column :survey_score
    column :value
    column 'Domain', &:domain
    column 'Subdomain', &:subdomain
    actions
  end
end
