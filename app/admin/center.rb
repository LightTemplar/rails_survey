# frozen_string_literal: true

ActiveAdmin.register Center do
  belongs_to :score_scheme
  navigation_menu :score_scheme

  actions :all, except: %i[destroy edit new]
  config.per_page = [50, 100]

  collection_action :download, method: :get do
    redirect_to resource_path
  end

  action_item :download, only: :index do
    link_to 'Download Center Scores', download_admin_score_scheme_centers_path(params[:score_scheme_id])
  end

  index do
    column :id do |center|
      link_to center.id, admin_score_scheme_center_path(params[:score_scheme_id], center.id)
    end
    column :identifier
    column :name
    column :center_type
    column :administration
    column :region
    column :department
    column :municipality
    actions
  end

  controller do
    def download
      score_scheme = ScoreScheme.find(params[:score_scheme_id])
      send_file Center.download(score_scheme), type: 'text/csv', filename:
      "#{score_scheme.title.split.join('_')}_center_scores_#{Time.now.to_i}.csv"
    end
  end
end
