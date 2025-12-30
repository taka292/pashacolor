class DailyTheme < ApplicationRecord
  belongs_to :color_theme

  # バリデーション
  validates :theme_date, presence: true, uniqueness: true

  # 今日のお題を取得（存在しなければ自動生成）
  def self.today_theme
    today = Date.current
    theme = find_by(theme_date: today)

    return theme if theme.present?

    # 今日のお題が存在しない場合は自動生成
    create_today_theme
  end

  private

  def self.create_today_theme
    today = Date.current

    # 過去12日間で使用された色を取得
    used_color_ids = where(theme_date: (today - 11.days)..today)
                     .pluck(:color_theme_id)

    # 使用されていない色を取得
    available_colors = ColorTheme.where.not(id: used_color_ids).active

    # すべて使用済みの場合は、全色から選択（次のサイクル）
    if available_colors.empty?
      available_colors = ColorTheme.active
    end

    # ランダムに1色を選択
    selected_color = available_colors.sample

    create!(
      color_theme_id: selected_color.id,
      theme_date: today
    )
  end
end
