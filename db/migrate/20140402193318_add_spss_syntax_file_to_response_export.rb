class AddSpssSyntaxFileToResponseExport < ActiveRecord::Migration[4.2]
  def change
    add_column :response_exports, :spss_syntax_file_url, :string
  end
end
