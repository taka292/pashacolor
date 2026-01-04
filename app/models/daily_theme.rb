class DailyTheme < ApplicationRecord
  belongs_to :user
  belongs_to :color_theme

  # バリデーション
  validates :theme_date, presence: true
  validates :theme_date, uniqueness: { scope: :user_id }

  # 今日のお題を取得（存在しなければ自動生成）
  def self.today_theme(user)
    today = Date.current
    theme = find_by(user: user, theme_date: today)

    return theme if theme.present?

    # 今日のお題が存在しない場合は自動生成
    create_today_theme(user)
  end

  private

  def self.create_today_theme(user)
    today = Date.current

    # ユーザーの現在のアクティブパレットを取得
    active_progress = user.palette_progresses.find_by(status: 'active')
    
    # アクティブパレットがなければ、最初の unlocked または completed パレット
    if active_progress.nil?
      active_progress = user.palette_progresses
                           .where(status: ['unlocked', 'completed'])
                           .joins(:color_palette)
                           .order('color_palettes.display_order ASC')
                           .first
    end
    
    # フォールバック: 基本パレット（新規ユーザー用）
    target_palette = active_progress&.color_palette || ColorPalette.find_by(display_order: 1)
    
    if target_palette.nil?
      raise "利用可能なカラーパレットが存在しません。管理者に連絡してください。"
    end

    # 対象パレットの色を取得
    palette_colors = target_palette.color_themes.active
    
    # パレットサイズに応じた日数で、そのパレット内の使用済み色を取得
    days_to_check = [palette_colors.count - 1, 0].max
    used_color_ids = where(user: user, theme_date: (today - days_to_check.days)..today)
                     .joins(:color_theme)
                     .where(color_themes: { color_palette_id: target_palette.id })
                     .pluck(:color_theme_id)

    # 未使用の色を取得
    available_colors = palette_colors.where.not(id: used_color_ids)

    # すべて使用済みの場合はリセット（次のサイクル）
    if available_colors.empty?
      available_colors = palette_colors
    end

    if available_colors.empty?
      raise "利用可能なカラーテーマが存在しません。管理者に連絡してください。"
    end

    # ランダムに選択
    selected_color = available_colors.sample

    create!(
      user: user,
      color_theme_id: selected_color.id,
      theme_date: today
    )
  end
end
