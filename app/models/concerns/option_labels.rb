module OptionLabels
  extend ActiveSupport::Concern

  def generate_labels(response, versioned_question)
    option_labels = []
    if response.question and versioned_question and versioned_question.has_non_special_options?
      if Settings.list_question_types.include?(response.question.question_type)
        option_labels << versioned_question.options.map(&:text)
      else
        response.text.split(Settings.list_delimiter).each do |option_index|
          (versioned_question.has_other? and option_index.to_i == versioned_question.other_index) ?
              option_labels << 'Other' : option_labels << versioned_question.options[option_index.to_i].to_s
        end
      end
    end
    option_labels.join(Settings.list_delimiter)
  end

end