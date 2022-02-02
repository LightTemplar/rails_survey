class AddImageToInstrumentQuestion < ActiveRecord::Migration[5.2]
  def change
    add_column :option_in_option_sets, :has_image, :boolean, default: false
  end
end
