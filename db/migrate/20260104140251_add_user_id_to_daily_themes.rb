class AddUserIdToDailyThemes < ActiveRecord::Migration[8.1]
  def up
    # 既存データを削除（user_id が必須になるため）
    DailyTheme.delete_all

    # user_id カラムを追加
    add_reference :daily_themes, :user, null: false, foreign_key: true

    # ユニーク制約を変更
    remove_index :daily_themes, :theme_date if index_exists?(:daily_themes, :theme_date)
    add_index :daily_themes, [:user_id, :theme_date], unique: true
  end

  def down
    # ユニーク制約を元に戻す
    remove_index :daily_themes, [:user_id, :theme_date] if index_exists?(:daily_themes, [:user_id, :theme_date])
    add_index :daily_themes, :theme_date, unique: true

    # user_id カラムを削除
    remove_reference :daily_themes, :user
  end
end
