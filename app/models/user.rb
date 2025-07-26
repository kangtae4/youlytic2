class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :omniauthable, omniauth_providers: [:google_oauth2, :kakao, :naver]

  has_many :analysis_reports, dependent: :destroy
  has_many :analyzed_channels, -> { distinct }, through: :analysis_reports, source: :channel

  enum subscription_tier: { free: 0, premium: 1, enterprise: 2 }

  validates :email, presence: true, uniqueness: true, allow_blank: true
  validates :subscription_tier, presence: true
  validates :provider, :uid, presence: true, if: :oauth_user?

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

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.first_name = auth.info.first_name || auth.info.name&.split(' ')&.first
      user.last_name = auth.info.last_name || auth.info.name&.split(' ')&.last
      user.provider = auth.provider
      user.uid = auth.uid
      user.subscription_tier = :free
      user.daily_api_quota = 5
      user.password = Devise.friendly_token[0, 20]
    end
  end

  def oauth_user?
    provider.present? && uid.present?
  end

  def email_required?
    !oauth_user?
  end

  def password_required?
    !oauth_user? && (!persisted? || !password.nil? || !password_confirmation.nil?)
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