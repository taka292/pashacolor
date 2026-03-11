class CreatePaletteProgresses < ActiveRecord::Migration[8.1]
  def change
    create_table :palette_progresses, force: :cascade do |t|
      t.references :user, null: false, foreign_key: true
      t.references :color_palette, null: false, foreign_key: true
      t.string :status, null: false, default: 'locked'
      t.datetime :unlocked_at
      t.datetime :completed_at
      t.timestamps
    end
    add_index :palette_progresses, [:user_id, :color_palette_id], unique: true
  end
end
