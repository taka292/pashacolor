class CreateColorPalettes < ActiveRecord::Migration[8.1]
  def change
    create_table :color_palettes, force: :cascade do |t|
      t.string :name, null: false
      t.text :description
      t.integer :display_order, null: false
      t.timestamps
    end
    add_index :color_palettes, :display_order, unique: true
  end
end
