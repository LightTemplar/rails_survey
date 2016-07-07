class ScoreUtils

  def self.generate_scorers(folder_name)
    reset_all
    book = Roo::Spreadsheet.open(folder_name + 'ObsScoringScheme.xlsx', extension: :xlsx)
    sheet1 = book.sheet('Sheet1')
    current_unit = Unit.new
    current_section = ScoreSection.new
    current_sub_section = ScoreSubSection.new
    sheet1.drop(1).each do |row|
      unless row[0].nil?
        if current_unit.name == row[0]
          Variable.create(result: row[1], name: row[2], value: row[3], next_variable: row[4], next_unit_name: row[5], unit_id: current_unit.id)
        else
          if current_section.name == row[7]
            unless current_sub_section.name == row[8]
              current_sub_section = ScoreSubSection.create(name: row[8], score_section_id: current_section.id)
            end
          else
            current_section = ScoreSection.create(name: row[7], instrument_id: row[9])
            current_sub_section = ScoreSubSection.create(name: row[8], score_section_id: current_section.id)
          end
          unit = Unit.create(name: row[0], weight: row[6], score_sub_section_id: current_sub_section.id, domain: row[10])
          Variable.create(result: row[1], name: row[2], value: row[3], next_variable: row[4], next_unit_name: row[5], unit_id: unit.id)
          current_unit = unit
        end
      end
    end
  end

  def self.reset_all
    Unit.delete_all
    ScoreSection.delete_all
    ScoreSubSection.delete_all
    Variable.delete_all
    reset_score_holders
  end

  def self.reset_score_holders
    SurveyScore.delete_all
    UnitScore.delete_all
  end

end