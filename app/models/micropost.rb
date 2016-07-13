class Micropost < ActiveRecord::Base
  belongs_to :user
  # descending order：降順（新しい方から古い方へ）
  default_scope -> { order(created_at: :desc) }
  mount_uploader :picture, PictureUploader
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
end
