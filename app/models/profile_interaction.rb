class ProfileInteraction < ApplicationRecord
  belongs_to :profile
  
  validates :action, presence: true, inclusion: { in: %w[right_swipe left_swipe] }
  validates :viewer_session, presence: true
  
  # Ensure we have tracking data for swipe actions
  validates :time_spent, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :scroll_depth, presence: true, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
end
