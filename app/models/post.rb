class Post < ApplicationRecord
  belongs_to :user
  belongs_to :color_theme

  # Active Storage（写真アップロード）
  has_one_attached :image

  # バリデーション
  validates :color_theme_id, presence: true
  validate :image_content_type
  validate :image_file_size

  # 画像の形式制限（JPEG, PNG, WebP）
  IMAGE_CONTENT_TYPES = %w[image/jpeg image/png image/webp].freeze
  # 画像のサイズ制限（10MB）
  MAX_IMAGE_SIZE = 10.megabytes

  # スコープ
  scope :public_posts, -> { where(is_public: true) }
  scope :private_posts, -> { where(is_public: false) }
  scope :recent, -> { order(posted_at: :desc) }
  scope :by_user, ->(user) { where(user_id: user.id) }

  # コールバック
  before_save :set_posted_at, if: -> { posted_at.nil? }

  private

  def set_posted_at
    self.posted_at ||= Time.current
  end

  def image_content_type
    return unless image.attached?

    unless IMAGE_CONTENT_TYPES.include?(image.content_type)
      errors.add(:image, :content_type)
    end
  end

  def image_file_size
    return unless image.attached?

    if image.byte_size > MAX_IMAGE_SIZE
      errors.add(:image, :file_size)
    end
  end
end
