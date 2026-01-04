class PaletteProgress < ApplicationRecord
  belongs_to :user
  belongs_to :color_palette

  # ステータスenum
  enum :status, { locked: 0, unlocked: 1, completed: 2, active: 3 }

  # バリデーション
  validates :status, presence: true

  # ステータス変更メソッド
  def unlock!
    update!(status: :unlocked, unlocked_at: Time.current)
  end

  def complete!
    update!(status: :completed, completed_at: Time.current)
  end

  def activate!
    update!(status: :active)
  end

  def deactivate!
    update!(status: :completed) if active?
  end

  # 進捗チェック（パレットの色が全て投稿されているか）
  def check_completion!
    return if status == 'completed'

    palette_colors = color_palette.color_themes.pluck(:id)
    posted_colors = user.posts.where(color_theme_id: palette_colors).distinct.pluck(:color_theme_id)

    if palette_colors.all? { |color_id| posted_colors.include?(color_id) }
      complete!
      unlock_next_palette!
    end
  end

  private

  def unlock_next_palette!
    next_palette = color_palette.next_palette
    return unless next_palette

    progress = user.palette_progresses.find_or_create_by!(color_palette: next_palette)
    progress.unlock! if progress.status == 'locked'
  end
end
