class ColorTheme < ApplicationRecord
  # バリデーション
  validates :color_name, presence: true
  validates :color_code, presence: true, format: { with: /\A#[0-9A-Fa-f]{6}\z/, message: "はHEX形式（#RRGGBB）で入力してください" }
  validates :display_order, presence: true, uniqueness: true

  # スコープ
  scope :active, -> { where(is_active: true) }
  scope :ordered, -> { order(display_order: :asc) }

  # HEXコードからRGB値を計算するメソッド
  def rgb_r
    return nil unless color_code.present?
    color_code[1..2].to_i(16)
  end

  def rgb_g
    return nil unless color_code.present?
    color_code[3..4].to_i(16)
  end

  def rgb_b
    return nil unless color_code.present?
    color_code[5..6].to_i(16)
  end

  # RGB値を配列で返す
  def rgb
    [rgb_r, rgb_g, rgb_b]
  end
end
