class ColorPalette < ApplicationRecord
  # 関連付け
  has_many :color_themes, foreign_key: :color_palette_id, dependent: :destroy
  has_many :palette_progresses, dependent: :destroy

  # バリデーション
  validates :name, presence: true
  validates :display_order, presence: true, uniqueness: true

  # スコープ
  scope :ordered, -> { order(display_order: :asc) }

  # 現在のアクティブパレットを取得（アクティブパレット優先）
  def self.current_palette_for(user)
    # アクティブパレットがあればそれを返す
    active_palette = user.active_palette
    return active_palette if active_palette

    # アクティブがない場合は最初の未完了パレット
    palettes = ordered
    palettes.each do |palette|
      progress = user.palette_progresses.find_by(color_palette: palette)
      return palette if progress.nil? || progress.status.in?(['unlocked', 'completed'])
    end
    palettes.first # フォールバック
  end

  # パレットがコンプリートされているかチェック
  def completed_by?(user)
    progress = user.palette_progresses.find_by(color_palette: self)
    progress&.status == 'completed'
  end

  # 次のパレットを取得
  def next_palette
    ColorPalette.where('display_order > ?', display_order).ordered.first
  end
end
