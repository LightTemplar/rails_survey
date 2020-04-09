# frozen_string_literal: true

namespace :db do
  task :centers, [:score_scheme_id] => :environment do |_t, args|
    score_scheme = ScoreScheme.find(args[:score_scheme_id].to_i)
    return if score_scheme.nil?

    CSV.foreach('config/centers.csv', headers: true) do |row|
      center = score_scheme.centers.find_by(identifier: row[4].strip)
      if center
        center.update_attributes(name: row[2].strip, center_type: row[0].strip,
                                 administration: row[1]&.strip || '', region: row[5]&.strip || '',
                                 department: row[6]&.strip || '', municipality: row[7]&.strip || '')
      else
        score_scheme.centers.create(identifier: row[4].strip, name: row[2].strip,
                                    center_type: row[0]&.strip, administration: row[1]&.strip || '',
                                    region: row[5]&.strip || '', department: row[6]&.strip || '',
                                    municipality: row[7]&.strip || '')
      end
    end
  end
end
