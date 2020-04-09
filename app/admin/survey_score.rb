# frozen_string_literal: true

ActiveAdmin.register SurveyScore do
  belongs_to :score_scheme
  navigation_menu :score_scheme

  actions :all, except: %i[destroy edit new]

  config.per_page = [50, 100]

  collection_action :score, method: :get do
    redirect_to resource_path
  end

  collection_action :download, method: :get do
    redirect_to resource_path
  end

  action_item :score do
    link_to 'Score', score_admin_score_scheme_survey_scores_path(params[:score_scheme_id])
  end

  action_item :download do
    link_to 'Download', download_admin_score_scheme_survey_scores_path(params[:score_scheme_id])
  end

  sidebar 'Survey Score Associations', only: :show do
    ul do
      li link_to 'Raw Scores', admin_survey_score_raw_scores_path(params[:id])
    end
  end

  index do
    column :id
    column :survey
    column 'Identifier', &:identifier
    column 'Score', :score_sum
    column 'Raw Scores', :raw_scores do |ss|
      link_to ss.raw_scores.size.to_s, admin_survey_score_raw_scores_path(ss.id)
    end
    actions
  end

  controller do
    def score
      score_scheme = ScoreScheme.find(params[:score_scheme_id])
      score_scheme.score
      redirect_to admin_score_scheme_survey_scores_path(params[:score_scheme_id])
    end

    def download
      score_scheme = ScoreScheme.find(params[:score_scheme_id])
      send_file score_scheme.download, type: 'text/csv', filename:
      "#{score_scheme.title.split.join('_')}_survey_scores_#{Time.now.to_i}.csv"
    end
  end
end
