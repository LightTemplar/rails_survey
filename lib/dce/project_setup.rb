# frozen_string_literal: true

class ProjectSetup
  attr_accessor :row, :project, :instrument, :translation_language, :prefix, :folder,
                :section, :display, :gender_iq

  def initialize(id)
    self.project = Project.find_by(id: id.to_i)
    return unless project.nil?

    Rake::Task['setup'].reenable
    Rake::Task['setup'].invoke
    self.project = Project.first
  end

  def setup_instrument
    self.instrument = project.instruments.find_or_create_by(title: 'DCE Choice Tasks')
    instrument.update(published: true, language: 'en')
    self.translation_language = 'sw'
    instrument.translations.find_or_create_by(language: translation_language)
              .update(title: 'DCE Kazi Za Kuchagua', active: true)
  end

  def files
    ["#{Rails.root}/files/dce/DCEMergeMen.csv",
     "#{Rails.root}/files/dce/DCEMergeWomen.csv"]
  end

  def setup_qs(filename, row)
    self.row = row
    qs = QuestionSet.find_or_create_by(title: filename.split('/').last.split('.').first)
    setup_folder(qs)
  end

  def setup_folder(q_set)
    self.prefix = q_set.title == 'DCEMergeWomen' ? 'F' : 'M'
    self.folder = q_set.folders.find_or_create_by(title: "#{prefix}#{row[4]}")
    q_set.reload
    folder.update(position: q_set.folders.size) if folder.position.nil?
  end

  def setup_section
    instrument.reload
    self.section = instrument.sections.find_or_create_by(title: "#{prefix}#{row[4]}")
    section.update(position: instrument.sections.size + 1, randomize_displays: row[4] != '0')
  end

  def setup_display
    section.reload
    instrument.reload
    self.display = section.displays.find_or_create_by(title: "#{prefix}#{row[4]}-#{row[6]}")
    display.update(instrument_id: instrument.id,
                   position: section.displays.size + 1,
                   instrument_position: instrument.displays.size + 1)
  end

  def setup_demographics
    section = instrument.sections.find_or_create_by(title: 'Demographics')
    section.update(position: 1)
    section.translations.find_or_create_by(language: translation_language).update(text: 'Wasifu')
    display = section.displays.find_or_create_by(title: 'Demographics')
    display.update(instrument_id: instrument.id, position: 1, instrument_position: 1)
    qs = QuestionSet.find_or_create_by(title: 'Demographics')
    folder = qs.folders.find_or_create_by(title: 'Demographics')
    folder.update(position: 1)
    qid = folder.questions.find_or_create_by(question_identifier: 'ParticipantID')
    qid.update(text: 'Participant ID', question_type: 'FREE_RESPONSE', question_set_id: qs.id,
               position: 1, identifies_survey: true)
    qid.translations.find_or_create_by(language: translation_language)
       .update(text: 'Nambari ya Mshiriki')
    iq = display.instrument_questions.find_or_create_by(identifier: 'ParticipantID')
    display.reload
    instrument.reload
    iq.update(instrument_id: instrument.id, question_id: qid.id,
              position: 1, number_in_instrument: 1)
    f = Option.find_or_create_by(identifier: 'Female')
    f.update(text: 'Female')
    f.translations.find_or_create_by(language: translation_language).update(text: 'Mwanamke')
    m = Option.find_or_create_by(identifier: 'Male')
    m.update(text: 'Male')
    m.translations.find_or_create_by(language: translation_language).update(text: 'Mwanamume')
    os = OptionSet.find_or_create_by(title: 'Gender')
    os.option_in_option_sets.find_or_create_by(option_id: f.id).update(number_in_question: 1)
    os.option_in_option_sets.find_or_create_by(option_id: m.id).update(number_in_question: 2)
    qg = folder.questions.find_or_create_by(question_identifier: 'Gender')
    qg.update(text: 'What is your gender?', question_type: 'SELECT_ONE', question_set_id: qs.id,
              position: 2, option_set_id: os.id)
    qg.translations.find_or_create_by(language: translation_language)
      .update(text: 'Jinsia yako ni gani?')
    giq = display.instrument_questions.find_or_create_by(identifier: 'Gender')
    display.reload
    instrument.reload
    giq.update(instrument_id: instrument.id, question_id: qg.id,
               position: 2, number_in_instrument: 2)
    self.gender_iq = giq
  end

  def setup_gender_skips(instrument_question)
    option = Option.find_by(identifier: 'Female') if prefix == 'M'
    option = Option.find_by(identifier: 'Male') if prefix == 'F'
    ms = giq_multiple_skip(instrument_question, option)
    return if ms.present?

    create_multiple_skip(instrument_question, option)
  end

  def create_multiple_skip(instrument_question, option)
    gender_iq.multiple_skips.create(skip_question_identifier: instrument_question.identifier,
                                    option_identifier: option.identifier,
                                    question_identifier: gender_iq.identifier)
  end

  def giq_multiple_skip(instrument_question, option)
    gender_iq.multiple_skips
             .where(skip_question_identifier: instrument_question.identifier)
             .where(option_identifier: option.identifier)
  end

  def setup_other_skips
    female_sections = instrument.sections.where('title LIKE ?', '% Women Only')
    option = Option.find_by(identifier: 'Male')
    setup_section_skips(female_sections, option)
    male_sections = instrument.sections.where('title LIKE ?', '% Men Only')
    option = Option.find_by(identifier: 'Female')
    setup_section_skips(male_sections, option)
  end

  def setup_section_skips(sections, option)
    sections.each do |section|
      section.instrument_questions.each do |iq|
        ms = giq_multiple_skip(iq, option)
        next if ms.present?

        create_multiple_skip(iq, option)
      end
    end
  end
end
