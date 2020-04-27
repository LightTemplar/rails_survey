# frozen_string_literal: true

class AddResponseToRawScore < ActiveRecord::Migration[5.1]
  def change
    add_column :raw_scores, :response_id, :integer
    add_column :domains, :weight, :float
    add_column :subdomains, :weight, :float
    remove_column :option_scores, :follow_up_qid, :string
    remove_column :option_scores, :position, :string
  end
end
