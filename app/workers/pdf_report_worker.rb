# frozen_string_literal: true

class PdfReportWorker
  include Sidekiq::Worker

  def perform(center_id, score_scheme_id)
    center = Center.find center_id
    score_scheme = ScoreScheme.find score_scheme_id
    unless center.ss_survey_scores(score_scheme_id).empty?
      ['en', 'es'].each do |language|
        pdf = ReportPdf.new(center, score_scheme, language)
        name = "#{Rails.root}/files/pdfs/#{center.identifier}-#{score_scheme.id}-#{language}.pdf"
        file = File.new(name, 'w+')
        pdf.save_as(file.path)
      end
    end
    ScoreScheme.transaction do
      score_scheme.reload
      score_scheme.update_attributes(progress: score_scheme.progress + 1)
    end
  end

end
