# frozen_string_literal: true

ActiveAdmin.register Instruction do
  actions :all, except: %i[new edit destroy]
  config.per_page = [100, 250, 500]

  collection_action :export, method: :get do
    redirect_to resource_path
  end

  action_item :export do
    link_to 'Export', export_admin_instructions_path
  end

  index do
    column :title do |instruction|
      raw instruction.title
    end
    column 'Questions' do |instruction|
      raw instruction.question_identifiers
    end
    column 'Option Sets' do |instruction|
      raw instruction.option_set_titles
    end
    column 'Subsections' do |instruction|
      raw instruction.display_titles
    end
    column 'English' do |instruction|
      raw instruction.text
    end
    column 'Swahili' do |instruction|
      raw instruction.translated 'sw'
    end
    column 'Amharic' do |instruction|
      raw instruction.translated 'am'
    end
    column 'Khmer' do |instruction|
      raw instruction.translated 'km'
    end
  end

  controller do
    def export
      filename = "instructions_#{DateTime.now.to_i}.csv"
      send_data Instruction.export,
                type: 'text/csv; charset=iso-8859-1; header=present',
                disposition: "attachment; filename=#{filename}"
    end
  end
end
