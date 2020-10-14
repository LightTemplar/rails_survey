# frozen_string_literal: true

ActiveAdmin.register SubdomainScore do
  belongs_to :survey_score
  navigation_menu :survey_score

  actions :all, except: %i[destroy edit new]
  config.per_page = [50, 100]

  index do
    column :id
    column :subdomain
    column :score_sum
  end
end
