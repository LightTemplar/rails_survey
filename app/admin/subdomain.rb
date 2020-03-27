# frozen_string_literal: true

ActiveAdmin.register Subdomain do
  belongs_to :domain
  navigation_menu :domain

  actions :all, except: %i[destroy edit new]

  sidebar 'Subdomain Associations', only: :show do
    ul do
      li link_to 'Raw Scores', admin_subdomain_subdomain_raw_scores_path(params[:id])
    end
  end

  index do
    column :id
    column :title
    column :domain
    column 'Raw Scores', :raw_scores do |sd|
      link_to sd.raw_scores.size.to_s, admin_subdomain_subdomain_raw_scores_path(sd.id)
    end
    actions
  end
end
