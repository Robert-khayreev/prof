class User < ApplicationRecord
  has_secure_password
  
  has_many :profiles, dependent: :destroy
  
  validates :email, presence: true, uniqueness: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }
  
  before_create :generate_session_token
  
  def regenerate_session_token
    update(session_token: SecureRandom.urlsafe_base64)
  end
  
  private
  
  def generate_session_token
    self.session_token = SecureRandom.urlsafe_base64
  end
end
