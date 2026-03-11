class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Active Storage
  has_one_attached :avatar

  # 関連付け
  has_many :posts, dependent: :destroy
  has_many :palette_progresses, dependent: :destroy

  # アクティブパレットを取得
  def active_palette
    palette_progresses.where(status: 'active').first&.color_palette
  end

  # パレットを選択（アクティブ化）
  def select_palette!(palette)
    # 他のアクティブパレットを解除
    palette_progresses.where(status: 'active').update_all(status: 'completed')

    # 指定パレットをアクティブ化
    progress = palette_progresses.find_or_create_by!(color_palette: palette)
    progress.activate!
    palette
  end

  # コールバック
  after_create :create_initial_palette_progress

  # バリデーション
  validates :name, presence: true, length: { maximum: 50 }

  private

  def create_initial_palette_progress
    # 基本パレットの進捗を自動作成（アクティブ状態で開始）
    basic_palette = ColorPalette.find_by(display_order: 1)
    if basic_palette
      palette_progresses.create!(color_palette: basic_palette, status: :active)
    end
  end
end
