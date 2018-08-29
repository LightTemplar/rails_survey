class AddRankResponsesToQuestion < ActiveRecord::Migration
  def change
    add_column :questions, :rank_responses, :boolean, default: false
    add_column :responses, :rank_order, :string
  end
end
