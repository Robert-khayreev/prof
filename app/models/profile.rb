class Profile < ApplicationRecord
  belongs_to :user, optional: true
  has_many :profile_interactions, dependent: :destroy
  has_many_attached :images
  
  validates :name, presence: true
  validates :age, presence: true, numericality: { only_integer: true, greater_than: 17, less_than: 100 }
  validates :description, length: { maximum: 500 }
  validates :height, numericality: { only_integer: true, greater_than: 0, less_than: 300 }, allow_nil: true
  validates :income_level, inclusion: { in: %w[0-30k 30k-50k 50k-75k 75k-100k 100k-150k 150k-200k 200k+] }, allow_nil: true
  validates :gender_identity, inclusion: { in: %w[male female non-binary genderqueer agender other] }, allow_nil: true
  
  scope :active, -> { where(active: true) }
  
  def total_views
    # In Tinder-style, views = total swipe actions (every view results in a swipe)
    profile_interactions.where(action: ['right_swipe', 'left_swipe']).count
  end
  
  def right_swipes
    profile_interactions.where(action: 'right_swipe').count
  end
  
  def left_swipes
    profile_interactions.where(action: 'left_swipe').count
  end
  
  def average_time_spent
    times = profile_interactions
              .where(action: ['right_swipe', 'left_swipe'])
              .where.not(time_spent: nil)
              .pluck(:time_spent)
    times.any? ? (times.sum.to_f / times.size).round(2) : 0
  end
  
  def average_scroll_depth
    depths = profile_interactions
              .where(action: ['right_swipe', 'left_swipe'])
              .where.not(scroll_depth: nil)
              .pluck(:scroll_depth)
    depths.any? ? (depths.sum.to_f / depths.size).round(2) : 0
  end
  
  def swipe_right_rate
    total = right_swipes + left_swipes
    total > 0 ? ((right_swipes.to_f / total) * 100).round(2) : 0
  end
  
  def average_images_viewed
    indices = profile_interactions
                .where(action: ['right_swipe', 'left_swipe'])
                .where.not(image_index: nil)
                .pluck(:image_index)
    indices.any? ? ((indices.sum.to_f / indices.size) + 1).round(2) : 0
  end
  
  def average_image_index_for_right_swipes
    indices = profile_interactions
                .where(action: 'right_swipe')
                .where.not(image_index: nil)
                .pluck(:image_index)
    indices.any? ? (indices.sum.to_f / indices.size).round(2) : nil
  end
  
  def average_image_index_for_left_swipes
    indices = profile_interactions
                .where(action: 'left_swipe')
                .where.not(image_index: nil)
                .pluck(:image_index)
    indices.any? ? (indices.sum.to_f / indices.size).round(2) : nil
  end
  
  def image_index_distribution
    profile_interactions
      .where(action: ['right_swipe', 'left_swipe'])
      .where.not(image_index: nil)
      .group(:image_index, :action)
      .count
  end
end
