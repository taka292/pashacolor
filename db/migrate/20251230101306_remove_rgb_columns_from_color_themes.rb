class RemoveRgbColumnsFromColorThemes < ActiveRecord::Migration[8.1]
  def change
    remove_column :color_themes, :rgb_r, :integer
    remove_column :color_themes, :rgb_g, :integer
    remove_column :color_themes, :rgb_b, :integer
  end
end
