# frozen_string_literal: true

ActiveAdmin.register ScoreUnit do
  belongs_to :subdomain
  navigation_menu :subdomain

  actions :all, except: %i[destroy edit new]
  config.per_page = [50, 100]

  index do
    column :id
    column :subdomain
    column :title
    column :score_type
    column :weight
    column :base_point_score
    column :institution_type
    column :notes
  end
end
