# frozen_string_literal: true

ActiveAdmin.register SurveyScore do
  belongs_to :score_scheme
  navigation_menu :score_scheme

  actions :all, except: %i[destroy edit new]

  config.per_page = [50, 100]

  member_action :score, method: :get do
    redirect_to resource_path
  end

  member_action :download, method: :get do
    redirect_to resource_path
  end

  action_item :score, only: :show do
    link_to 'Score', score_admin_score_scheme_survey_score_path(params[:score_scheme_id], params[:id])
  end

  action_item :download, only: :show do
    link_to 'Download', download_admin_score_scheme_survey_score_path(params[:score_scheme_id], params[:id])
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
      survey_score = SurveyScore.find params[:id]
      survey_score.score
      redirect_to admin_score_scheme_survey_score_path(params[:score_scheme_id], params[:id])
    end

    def download
      survey_score = SurveyScore.find params[:id]
      filename = survey_score.identifier
      filename = survey_score.title if filename.blank?
      send_file survey_score.download, type: 'text/csv', filename:
      "#{filename}_#{Time.now.to_i}.csv"
    end
  end
end
