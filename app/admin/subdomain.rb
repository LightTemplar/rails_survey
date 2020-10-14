# frozen_string_literal: true

ActiveAdmin.register Subdomain do
  belongs_to :domain
  navigation_menu :domain

  actions :all, except: %i[destroy edit new show]

  index do
    column :id
    column :title
    column :domain
    column :name
    column 'Score Units', :score_units do |subdomain|
      link_to subdomain.score_units.size.to_s, admin_subdomain_score_units_path(subdomain.id)
    end
  end
end
