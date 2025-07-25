class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :analysis_reports, dependent: :destroy
  has_many :analyzed_channels, -> { distinct }, through: :analysis_reports, source: :channel

  enum subscription_tier: { free: 0, premium: 1, enterprise: 2 }

  validates :email, presence: true, uniqueness: true
  validates :subscription_tier, presence: true

  def full_name
    "#{first_name} #{last_name}".strip
  end

  def can_analyze?
    return true if premium? || enterprise?
    
    reset_quota_if_needed
    api_requests_count < daily_api_quota
  end

  def increment_api_usage!
    reset_quota_if_needed
    increment!(:api_requests_count)
  end

  def remaining_quota
    return Float::INFINITY if premium? || enterprise?
    
    reset_quota_if_needed
    [daily_api_quota - api_requests_count, 0].max
  end

  private

  def reset_quota_if_needed
    today = Date.current
    
    if last_quota_reset != today
      update!(
        api_requests_count: 0,
        last_quota_reset: today
      )
    end
  end
end