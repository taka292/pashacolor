class DailyTheme < ApplicationRecord
  belongs_to :color_theme
  belongs_to :user

  # バリデーション
  validates :theme_date, presence: true
  validates :user_id, uniqueness: { scope: :theme_date }

  # 今日のお題を取得（存在しなければ自動生成）
  def self.today_theme(user)
    today = Date.current
    theme = find_by(user_id: user.id, theme_date: today)

    return theme if theme.present?

    # 今日のお題が存在しない場合は自動生成
    create_today_theme(user)
  end

  private

  def self.create_today_theme(user)
    today = Date.current

    # 過去12日間で使用された色を取得（ユーザーごと）
    used_color_ids = where(user_id: user.id, theme_date: (today - 11.days)..today)
                     .pluck(:color_theme_id)

    # 使用されていない色を取得
    available_colors = ColorTheme.where.not(id: used_color_ids).active

    # すべて使用済みの場合は、全色から選択（次のサイクル）
    if available_colors.empty?
      available_colors = ColorTheme.active
    end

    # 有効な色が存在しない場合はエラー
    if available_colors.empty?
      raise "利用可能なカラーテーマが存在しません。管理者に連絡してください。"
    end

    # ランダムに1色を選択
    selected_color = available_colors.sample

    create!(
      user_id: user.id,
      color_theme_id: selected_color.id,
      theme_date: today
    )
  end
end
