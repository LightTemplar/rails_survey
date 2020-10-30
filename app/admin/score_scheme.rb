# frozen_string_literal: true

ActiveAdmin.register ScoreScheme do
  belongs_to :project
  navigation_menu :project

  config.filters = false

  actions :all, except: %i[destroy edit new]

  member_action :score, method: :get do
    redirect_to resource_path
  end

  action_item :score, only: :show do
    link_to 'Generate Scores', score_admin_project_score_scheme_path(params[:project_id], params[:id])
  end

  sidebar 'Score Scheme Associations', only: :show do
    ul do
      li link_to 'Survey Scores', admin_score_scheme_survey_scores_path(params[:id])
      li link_to 'Center Scores', admin_score_scheme_centers_path(params[:id])
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
  end
end
