# frozen_string_literal: true

ActiveAdmin.register ScoreScheme do
  belongs_to :project
  navigation_menu :project

  config.filters = false

  actions :all, except: %i[destroy edit new]

  member_action :score, method: :get do
    redirect_to resource_path
  end

  member_action :download, method: :get do
    redirect_to resource_path
  end

  action_item :score, only: :show do
    link_to 'Score', score_admin_project_score_scheme_path(params[:project_id], params[:id])
  end

  action_item :download, only: :show do
    link_to 'Download', download_admin_project_score_scheme_path(params[:project_id], params[:id])
  end

  sidebar 'Scheme Associations', only: :show do
    ul do
      li link_to 'Centers', admin_score_scheme_centers_path(params[:id])
      li link_to 'Scores', admin_score_scheme_survey_scores_path(params[:id])
      li link_to 'Domains', admin_score_scheme_domains_path(params[:id])
    end
  end

  index do
    column :id
    column :instrument
    column :title
    column :active
    column 'Survey Scores', :survey_scores do |ss|
      link_to ss.survey_scores.size.to_s, admin_score_scheme_survey_scores_path(ss.id)
    end
    actions
  end

  controller do
    def score
      score_scheme = ScoreScheme.find(params[:id])
      score_scheme.score
      redirect_to admin_project_score_scheme_path(params[:project_id], params[:id])
    end

    def download
      score_scheme = ScoreScheme.find(params[:id])
      send_file score_scheme.download, type: 'text/csv', filename:
      "#{score_scheme.title.split.join('_')}_survey_scores_#{Time.now.to_i}.csv"
    end
  end
end
