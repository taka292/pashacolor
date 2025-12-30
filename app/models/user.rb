class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # Active Storage
  has_one_attached :avatar

  # 関連付け
  has_many :posts, dependent: :destroy

  # バリデーション
  validates :name, presence: true, length: { maximum: 50 }
end
