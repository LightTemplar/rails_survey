# frozen_string_literal: true

ActiveAdmin.register Domain do
  belongs_to :score_scheme
  navigation_menu :score_scheme

  actions :all, except: %i[destroy edit new show]
  config.filters = false

  index do
    column :id
    column :title
    column :name
    column 'Subdomains', :subdomains do |domain|
      link_to domain.subdomains.size.to_s, admin_domain_subdomains_path(domain.id)
    end
    column 'Score Units', :score_units do |domain|
      domain.score_units.size.to_s
    end
  end

  controller do
    def scoped_collection
      super.where(score_scheme_id: params[:score_scheme_id])
    end
  end
end
