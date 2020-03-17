# frozen_string_literal: true

ActiveAdmin.register SurveyScore do
  belongs_to :score_scheme
  navigation_menu :score_scheme

  actions :all, except: %i[destroy edit new]

  config.per_page = [50, 100]

  collection_action :score_surveys, method: :get do
    redirect_to resource_path
  end

  action_item :score_surveys do
    link_to 'Score Surveys', score_surveys_admin_score_scheme_survey_scores_path(params[:score_scheme_id])
  end

  sidebar 'Survey Score Associations', only: :show do
    ul do
      li link_to 'Raw Scores', admin_survey_score_raw_scores_path(params[:id])
    end
  end

  index do
    column :id
    column :survey
    column 'Raw Score', &:raw_score_sum
    column 'Weighted Score', &:weighted_score_sum
    column 'Raw Scores', :raw_scores do |ss|
      link_to ss.raw_scores.size.to_s, admin_survey_score_raw_scores_path(ss.id)
    end
    actions
  end

  controller do
    def score_surveys
      score_scheme = ScoreScheme.find(params[:score_scheme_id])
      score_scheme.score_surveys
      redirect_to admin_score_scheme_survey_scores_path(params[:score_scheme_id])
    end
  end
end
