class AddUserIdToDailyThemes < ActiveRecord::Migration[8.1]
  def up
    return unless table_exists?(:daily_themes)

    # 既存データを削除（user_id が必須になるため）
    # マイグレーション内でアプリのモデル定数に依存しないようにする
    execute("DELETE FROM daily_themes")

    # user_id カラムを追加
    if table_exists?(:users) && !column_exists?(:daily_themes, :user_id)
      add_reference :daily_themes, :user, null: false, foreign_key: true
    end

    # ユニーク制約を変更
    remove_index :daily_themes, :theme_date if index_exists?(:daily_themes, :theme_date)
    unless index_exists?(:daily_themes, [:user_id, :theme_date])
      add_index :daily_themes, [:user_id, :theme_date], unique: true
    end
  end

  def down
    return unless table_exists?(:daily_themes)

    # ユニーク制約を元に戻す
    remove_index :daily_themes, [:user_id, :theme_date] if index_exists?(:daily_themes, [:user_id, :theme_date])
    unless index_exists?(:daily_themes, :theme_date)
      add_index :daily_themes, :theme_date, unique: true
    end

    # user_id カラムを削除
    remove_reference :daily_themes, :user if column_exists?(:daily_themes, :user_id)
  end
end
