# frozen_string_literal: true

ActiveAdmin.register Domain do
  belongs_to :score_scheme
  navigation_menu :score_scheme

  actions :all, except: %i[destroy edit new]

  sidebar 'Domain Associations', only: :show do
    ul do
      li link_to 'Subdomains', admin_domain_subdomains_path(params[:id])
    end
  end

  index do
    column :id
    column :title
    column :score_scheme
    actions
  end
end
