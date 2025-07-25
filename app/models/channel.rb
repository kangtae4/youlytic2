class Channel < ApplicationRecord
  has_many :videos, dependent: :destroy
  has_many :analysis_reports, dependent: :destroy
  has_many :channel_snapshots, dependent: :destroy

  validates :youtube_id, presence: true, uniqueness: true
  validates :title, presence: true

  scope :popular, -> { order(subscriber_count: :desc) }
  scope :recently_analyzed, -> { order(last_analyzed_at: :desc) }

  def update_from_youtube_data!(data)
    snippet = data['snippet'] || {}
    statistics = data['statistics'] || {}
    branding = data['brandingSettings'] || {}

    update!(
      title: snippet['title'],
      description: snippet['description'],
      thumbnail_url: snippet.dig('thumbnails', 'default', 'url'),
      country: snippet['country'],
      default_language: snippet['defaultLanguage'],
      published_at: snippet['publishedAt']&.to_datetime,
      
      statistics: statistics,
      branding_settings: branding,
      
      subscriber_count: statistics['subscriberCount'].to_i,
      video_count: statistics['videoCount'].to_i,
      view_count: statistics['viewCount'].to_i,
      
      last_analyzed_at: Time.current
    )

    increment!(:analysis_count)
  end

  def subscriber_count_formatted
    format_count(subscriber_count)
  end

  def view_count_formatted
    format_count(view_count)
  end

  def average_views_per_video
    return 0 if video_count.zero?
    (view_count.to_f / video_count).round
  end

  def engagement_rate
    return 0 if videos.empty?
    
    total_engagement = videos.sum { |v| v.like_count + v.comment_count }
    total_views = videos.sum(:view_count)
    
    return 0 if total_views.zero?
    (total_engagement.to_f / total_views * 100).round(2)
  end

  def create_snapshot!
    today = Date.current
    
    channel_snapshots.find_or_create_by!(snapshot_date: today) do |snapshot|
      snapshot.subscriber_count = subscriber_count
      snapshot.video_count = video_count
      snapshot.view_count = view_count
    end
  end

  private

  def format_count(count)
    case count
    when 0...1_000
      count.to_s
    when 1_000...1_000_000
      "#{(count / 1_000.0).round(1)}K"
    when 1_000_000...1_000_000_000
      "#{(count / 1_000_000.0).round(1)}M"
    else
      "#{(count / 1_000_000_000.0).round(1)}B"
    end
  end
end