class AddColorPaletteToColorThemes < ActiveRecord::Migration[8.1]
  def up
    # カラムが存在しない場合のみ追加
    unless column_exists?(:color_themes, :color_palette_id)
      add_column :color_themes, :color_palette_id, :integer
      add_foreign_key :color_themes, :color_palettes, column: :color_palette_id
    end

    # 既存の色データを基本パレットに割り当て
    basic_palette = ColorPalette.find_by(display_order: 1)
    if basic_palette
      ColorTheme.where(color_palette_id: nil).update_all(color_palette_id: basic_palette.id)
    end
  end

  def down
    # ロールバック時にカラムを削除
    if column_exists?(:color_themes, :color_palette_id)
      remove_foreign_key :color_themes, column: :color_palette_id
      remove_column :color_themes, :color_palette_id
    end
  end
end
