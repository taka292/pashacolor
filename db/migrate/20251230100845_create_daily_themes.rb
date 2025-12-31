class CreateDailyThemes < ActiveRecord::Migration[8.1]
  def change
    create_table :daily_themes do |t|
      t.references :color_theme, null: false, foreign_key: true
      t.date :theme_date, null: false
      t.text :description

      t.timestamps
    end

    add_index :daily_themes, :theme_date, unique: true
  end
end
