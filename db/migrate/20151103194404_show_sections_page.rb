class ShowSectionsPage < ActiveRecord::Migration[4.2]
  def change
    add_column :instruments, :show_sections_page, :boolean, default: false
    add_column :instruments, :navigate_to_review_page, :boolean, default: false
  end
end
