# frozen_string_literal: true

ActiveAdmin.register ScoreScheme do
  belongs_to :project
  navigation_menu :project

  actions :all, except: %i[destroy edit new]

  sidebar 'Scheme Associations', only: :show do
    ul do
      li link_to 'Scores', admin_score_scheme_survey_scores_path(params[:id])
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
end
