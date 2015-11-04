class ShowSectionsPage < ActiveRecord::Migration
  def change
    add_column :instruments, :show_sections_page, :boolean, default: false
    add_column :instruments, :navigate_to_review_page, :boolean, default: false
  end
end