class Qrcode < ApplicationRecord
  validates :url, presence: true, format: URI::regexp(%w[http https])
  before_create :generate_token
  before_create :set_expiration

  private
  def generate_token
    self.token = SecureRandom.hex(10)
  end

  def set_expiration
    self.expires_at = 1.day.from_now
  end
end
