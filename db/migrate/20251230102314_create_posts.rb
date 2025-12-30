class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.references :user, null: false, foreign_key: true
      t.references :color_theme, null: false, foreign_key: true
      t.text :description
      t.decimal :latitude, precision: 10, scale: 7
      t.decimal :longitude, precision: 10, scale: 7
      t.string :location_name
      t.boolean :is_public, default: false, null: false
      t.datetime :posted_at

      t.timestamps
    end

    add_index :posts, :posted_at
  end
end
