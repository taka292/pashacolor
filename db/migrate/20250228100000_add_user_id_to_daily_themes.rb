class AddUserIdToDailyThemes < ActiveRecord::Migration[8.1]
  def change
    unless column_exists?(:daily_themes, :user_id)
      add_reference :daily_themes, :user, null: false, foreign_key: true
    end

    # 既存のtheme_dateのユニーク制約を変更（user_idとの複合一意制約に）
    if index_exists?(:daily_themes, :theme_date)
      remove_index :daily_themes, :theme_date
    end
    unless index_exists?(:daily_themes, [:user_id, :theme_date])
      add_index :daily_themes, [:user_id, :theme_date], unique: true
    end
  end
end
