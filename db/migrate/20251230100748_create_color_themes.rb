class CreateColorThemes < ActiveRecord::Migration[8.1]
  def change
    create_table :color_themes do |t|
      t.string :color_name, null: false
      t.string :color_code, null: false
      t.integer :rgb_r, null: false
      t.integer :rgb_g, null: false
      t.integer :rgb_b, null: false
      t.text :description
      t.boolean :is_active, default: true, null: false
      t.integer :display_order, null: false

      t.timestamps
    end

    add_index :color_themes, :display_order
    add_index :color_themes, :is_active
  end
end
