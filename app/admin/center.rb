# frozen_string_literal: true

ActiveAdmin.register Center do
  belongs_to :score_scheme
  navigation_menu :score_scheme

  actions :all, except: %i[destroy edit new]
  config.per_page = [50, 100]
  config.filters = false
  config.sort_order = 'id_asc'

  collection_action :download, method: :get do
    redirect_to resource_path
  end

  member_action :download_red_flags, method: :get do
    redirect_to resource_path
  end

  member_action :download_scores, method: :get do
    redirect_to resource_path
  end

  action_item :download, only: :index do
    link_to 'Download', download_admin_score_scheme_centers_path(params[:score_scheme_id])
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
    column 'Surveys' do |center|
      center.survey_count(params[:score_scheme_id])
    end
    column 'Red Flags' do |center|
      link_to 'Download', download_red_flags_admin_score_scheme_center_path(params[:score_scheme_id], center.id)
    end
    column 'Score Reports' do |center|
      span { link_to 'English', download_scores_admin_score_scheme_center_path(params[:score_scheme_id], center.id, language: 'en') }
      span { link_to 'Spanish', download_scores_admin_score_scheme_center_path(params[:score_scheme_id], center.id, language: 'es') }
    end
  end

  controller do
    def download
      score_scheme = ScoreScheme.find(params[:score_scheme_id])
      send_file Center.download(score_scheme), type: 'application/zip',
                                               filename: "#{score_scheme.title.split.join('_')}_center_scores_#{Time.now.to_i}.zip"
    end

    def download_red_flags
      score_scheme = ScoreScheme.find(params[:score_scheme_id])
      center = Center.find params[:id]
      send_file center.red_flags(score_scheme), type: 'text/csv',
                                                filename: "#{center.identifier}_red_flags_#{Time.now.to_i}.csv"
    end

    def download_scores
      score_scheme = ScoreScheme.find(params[:score_scheme_id])
      center = Center.find params[:id]
      send_file center.formatted_scores(score_scheme, params[:language]), type: 'text/xlsx',
                                                                          filename: "#{center.identifier}-#{params[:language]}-#{Time.now.to_i}.xlsx"
    end
  end
end
