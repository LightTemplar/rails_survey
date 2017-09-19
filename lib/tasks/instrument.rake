namespace :instrument do
  task :copy, %i[instrument_id project_id] => [:environment] do |t, args|
    instrument = Instrument.find(args[:instrument_id].to_i)
    project_id = args[:project_id]

    Instrument.skip_callback(:save, :before, :update_question_count)
    Instrument.skip_callback(:update, :after, :update_special_options)
    Instrument.paper_trail_off!
    i = instrument.dup
    i.project_id = project_id.to_i
    i.published = false
    i.save(validate: false)
    Instrument.set_callback(:save, :before, :update_question_count)
    Instrument.set_callback(:update, :after, :update_special_options)
    Instrument.paper_trail_on!

    instrument.rules.each do |rule|
      r = rule.dup
      r.instrument_id = i.id
      r.save(validate: false)
    end

    instrument.randomized_factors.each do |factor|
      rf = factor.dup
      rf.instrument_id = i.id
      rf.save(validate: false)

      rf.randomized_options.each do |option|
        ro = option.dup
        ro.randomized_factor_id = rf.id
        ro.save(validate: false)
      end
    end

    InstrumentTranslation.skip_callback(:save, :after, :deactive_language_translations)
    instrument.translations.each do |translation|
      t = translation.dup
      t.instrument_id = i.id
      t.save(validate: false)
    end
    InstrumentTranslation.set_callback(:save, :after, :deactive_language_translations)

    Question.paper_trail_off!
    Question.skip_callback(:save, :before, :update_instrument_version)
    Question.skip_callback(:save, :before, :update_question_translation)
    Question.skip_callback(:save, :after, :record_instrument_version)
    Question.skip_callback(:destroy, :before, :update_instrument_version)
    Question.skip_callback(:update, :after, :update_dependent_records)
    Question.skip_callback(:create, :after, :create_special_options)

    Grid.skip_callback(:save, :after, :update_question_types)
    Grid.paper_trail_off!
    instrument.grids.each do |grid|
      g = grid.dup
      g.instrument_id = i.id
      g.save(validate: false)

      grid.grid_translations.each do |translation|
        t = translation.dup
        t.grid_id = grid.id
        t.save(validate: false)
      end

      Grid.paper_trail_off!
      grid.grid_labels.each do |grid_label|
        gl = grid_label.dup
        gl.grid_id = g.id
        gl.save(validate: false)

        grid_label.grid_label_translations.each do |translation|
          t = translation.dup
          t.grid_label_id = grid_label.id
          t.save(validate: false)
        end
      end
      Grid.paper_trail_on!

      grid.questions.each do |question|
        q = Question.find_by_question_identifier("#{question.question_identifier}_#{project_id}")
        next unless q.nil?
        del_q = Question.only_deleted.where(question_identifier: "#{question.question_identifier}_#{project_id}").try(:first)
        del_q.really_destroy! if del_q
        q = question.dup
        q.question_identifier = "#{question.question_identifier}_#{project_id}"
        q.grid_id = g.id
        q.following_up_question_identifier = "#{question.following_up_question_identifier}_#{project_id}" unless question.following_up_question_identifier.blank?
        q.instrument_id = i.id
        q.save(validate: false)
      end
    end
    Grid.set_callback(:save, :after, :update_question_types)
    Grid.paper_trail_on!

    Section.skip_callback(:save, :before, :update_section_translation)
    Section.skip_callback(:save, :before, :update_instrument_version)
    Section.skip_callback(:destroy, :before, :update_instrument_version)
    Section.skip_callback(:destroy, :before, :unset_section_questions)
    instrument.sections.each do |section|
      s = section.dup
      s.instrument_id = i.id
      s.save(validate: false)

      section.translations.each do |translation|
        t = translation.dup
        t.section_id = s.id
        t.save(validate: false)
      end

      section.questions.each do |question|
        q = Question.find_by_question_identifier("#{question.question_identifier}_#{project_id}")
        next unless q.nil?
        del_q = Question.only_deleted.where(question_identifier: "#{question.question_identifier}_#{project_id}").try(:first)
        del_q.really_destroy! if del_q
        q = question.dup
        q.question_identifier = "#{question.question_identifier}_#{project_id}"
        q.section_id = s.id
        q.following_up_question_identifier = "#{question.following_up_question_identifier}_#{project_id}" unless question.following_up_question_identifier.blank?
        q.instrument_id = i.id
        q.save!
      end
    end
    Section.set_callback(:save, :before, :update_section_translation)
    Section.set_callback(:save, :before, :update_instrument_version)
    Section.set_callback(:destroy, :before, :update_instrument_version)
    Section.set_callback(:destroy, :before, :unset_section_questions)

    instrument.questions.each do |question|
      q = Question.find_by_question_identifier("#{question.question_identifier}_#{project_id}")
      if q.nil?
        del_q = Question.only_deleted.where(question_identifier: "#{question.question_identifier}_#{project_id}").try(:first)
        del_q.really_destroy! if del_q
        q = question.dup
        q.question_identifier = "#{question.question_identifier}_#{project_id}"
        q.following_up_question_identifier = "#{question.following_up_question_identifier}_#{project_id}" unless question.following_up_question_identifier.blank?
        q.instrument_id = i.id
        q.save(validate: false)
      end

      Image.skip_callback(:save, :before, :touch_question)
      question.images.each do |image|
        im = image.dup
        im.question_id = q.id
        im.save(validate: false)
      end
      Image.set_callback(:save, :before, :touch_question)

      question.translations.each do |translation|
        t = translation.dup
        t.question_id = q.id
        t.save(validate: false)
      end

      Option.paper_trail_off!
      Option.skip_callback(:save, :before, :update_instrument_version)
      Option.skip_callback(:save, :before, :update_option_translation)
      Option.skip_callback(:destroy, :before, :update_instrument_version)
      Option.skip_callback(:save, :after, :record_instrument_version_number)
      Option.skip_callback(:save, :after, :sanitize_next_question)
      Option.skip_callback(:save, :after, :check_parent_criticality)
      question.options.each do |option|
        next if option.special
        o = option.dup
        o.next_question = "#{option.next_question}_#{project_id}" unless option.next_question.blank?
        o.question_id = q.id
        o.save(validate: false)

        Skip.skip_callback(:save, :before, :touch_parents)
        option.skips.each do |skip|
          s = skip.dup
          s.question_identifier = "#{skip.question_identifier}_#{project_id}" unless skip.question_identifier.blank?
          s.option_id = o.id
          s.save(validate: false)
        end
        Skip.set_callback(:save, :before, :touch_parents)

        option.translations.each do |translation|
          t = translation.dup
          t.option_id = o.id
          t.save(validate: false)
        end
      end
      Option.paper_trail_on!
      Option.set_callback(:save, :before, :update_instrument_version)
      Option.set_callback(:save, :before, :update_option_translation)
      Option.set_callback(:destroy, :before, :update_instrument_version)
      Option.set_callback(:save, :after, :record_instrument_version_number)
      Option.set_callback(:save, :after, :sanitize_next_question)
      Option.set_callback(:save, :after, :check_parent_criticality)
    end
    Question.set_callback(:save, :before, :update_instrument_version)
    Question.set_callback(:save, :before, :update_question_translation)
    Question.set_callback(:save, :after, :record_instrument_version)
    Question.set_callback(:destroy, :before, :update_instrument_version)
    Question.set_callback(:update, :after, :update_dependent_records)
    Question.set_callback(:create, :after, :create_special_options)
    Question.paper_trail_on!

    i.translations.each(&:assign_old_translations)
  end
end
