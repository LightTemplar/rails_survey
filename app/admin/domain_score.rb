# frozen_string_literal: true

ActiveAdmin.register DomainScore do
  belongs_to :survey_score
  navigation_menu :survey_score

  actions :all, except: %i[destroy edit new]

  index do
    column :id
    column :domain
    column :score_sum
  end
end
