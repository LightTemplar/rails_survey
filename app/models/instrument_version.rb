class InstrumentVersion
  attr_accessor :instrument, :version

  def method_missing(method, *args, &block)
    if Instrument.method_defined?(method)
      if @version
        @version.reify.send(method, *args, &block)
      else
        @instrument.send(method, *args, &block)
      end
    else
      super
    end
  end

  def self.build(params = {})
    instrument = Instrument.find(params[:instrument_id])
    version_number = params[:version_number].to_i
    instrument_version = InstrumentVersion.new
    instrument_version.instrument = instrument
    if instrument.current_version_number > version_number
      versions = Rails.cache.fetch("instrument_versions-#{instrument.id}", expires_in: 30.minutes) { instrument.versions }
      instrument_version.version = Rails.cache.fetch("instrument_versions-#{instrument.id}-#{version_number}", expires_in: 30.minutes) do
        versions[version_number]
      end
    end
    instrument_version
  end

  def questions
    unless @version
      return Rails.cache.fetch("questions-#{@instrument.id}", expires_in: 30.minutes) do
        @instrument.questions
      end
    end
    Rails.cache.fetch("questions-#{@instrument.id}-#{@version.id}", expires_in: 30.minutes) do
      questions = []
      @version.reify.questions.with_deleted.each do |question|
        versioned_question = versioned(question)
        next unless versioned_question
        questions << versioned_question
        options = options_for_question(versioned_question)
        versioned_question.define_singleton_method(:options) { options }
      end
      questions
    end
  end

  def find_question_by(options = {})
    finder, value = options.first
    unless @version
      return Rails.cache.fetch("f_q_b-#{@instrument.id}-#{finder}-#{value}", expires_in: 30.minutes) do
        @instrument.questions.send("find_by_#{finder}".to_sym, value)
      end
    end
    question = Rails.cache.fetch("f_q_b_v-#{@instrument.id}-#{finder}-#{value}-#{@version.id}", expires_in: 30.minutes) do
      @version.reify.questions.send("find_by_#{finder}".to_sym, value)
    end
    return nil unless question
    versioned_question = versioned(question)
    options = options_for_question(versioned_question)
    versioned_question.define_singleton_method(:options) { options }
    versioned_question
  end

  def versioned(object)
    return object unless @version
    Rails.cache.fetch("versioned-#{@instrument.id}-#{object.class.name}-#{object.id}-#{@version.id}", expires_in: 30.minutes) do
      object.version_at(@version.created_at)
    end
  end

  private

  def options_for_question(question)
    return [] unless question
    unless @version
      return Rails.cache.fetch("o_f_q-#{@instrument.id}-#{question.question_identifier}", expires_in: 30.minutes) do
        question.options
      end
    end
    Rails.cache.fetch("o_f_q-#{@instrument.id}-#{question.question_identifier}-#{@version.id}", expires_in: 30.minutes) do
      options = []
      question.options.with_deleted.each do |option|
        options << versioned(option) if versioned(option)
      end
      options
    end
  end
end
