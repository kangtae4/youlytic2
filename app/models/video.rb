class Video < ApplicationRecord
  belongs_to :channel

  validates :youtube_id, presence: true, uniqueness: true
  validates :title, presence: true

  scope :popular, -> { order(view_count: :desc) }
  scope :recent, -> { order(published_at: :desc) }
  scope :high_engagement, -> { where('engagement_rate > ?', 5.0) }

  def update_from_youtube_data!(data)
    snippet = data['snippet'] || {}
    statistics = data['statistics'] || {}
    content_details = data['contentDetails'] || {}

    update!(
      title: snippet['title'],
      description: snippet['description'],
      thumbnail_url: snippet.dig('thumbnails', 'default', 'url'),
      published_at: snippet['publishedAt']&.to_datetime,
      category_id: snippet['categoryId'],
      default_language: snippet['defaultLanguage'],
      
      statistics: statistics,
      
      view_count: statistics['viewCount'].to_i,
      like_count: statistics['likeCount'].to_i,
      comment_count: statistics['commentCount'].to_i,
      
      duration_seconds: parse_duration(content_details['duration'])
    )

    calculate_engagement_rate!
    estimate_revenue!
  end

  def duration_formatted
    return "N/A" if duration_seconds.nil?
    
    hours = duration_seconds / 3600
    minutes = (duration_seconds % 3600) / 60
    seconds = duration_seconds % 60
    
    if hours > 0
      "%d:%02d:%02d" % [hours, minutes, seconds]
    else
      "%d:%02d" % [minutes, seconds]
    end
  end

  def view_count_formatted
    format_count(view_count)
  end

  def like_count_formatted
    format_count(like_count)
  end

  def engagement_rate_percentage
    "#{engagement_rate}%"
  end

  def estimated_revenue_range
    return "N/A" if estimated_revenue_min.nil? || estimated_revenue_max.nil?
    "$#{estimated_revenue_min.to_i} - $#{estimated_revenue_max.to_i}"
  end

  def days_since_published
    return 0 unless published_at
    (Time.current - published_at) / 1.day
  end

  def views_per_day
    days = days_since_published
    return 0 if days.zero?
    (view_count.to_f / days).round
  end

  private

  def calculate_engagement_rate!
    return if view_count.zero?
    
    total_engagement = like_count + comment_count
    rate = (total_engagement.to_f / view_count * 100).round(4)
    
    update_column(:engagement_rate, rate)
  end

  def estimate_revenue!
    return if view_count.zero?
    
    # Basic CPM model: $0.5 - $5 per 1000 views
    base_cpm_min = 0.5
    base_cpm_max = 5.0
    
    # Adjust based on engagement rate
    engagement_multiplier = [1.0 + (engagement_rate || 0) / 100, 2.0].min
    
    # Adjust based on channel size
    channel_multiplier = case channel.subscriber_count
    when 0...10_000
      0.8
    when 10_000...100_000
      1.0
    when 100_000...1_000_000
      1.3
    else
      1.5
    end
    
    views_in_thousands = view_count / 1000.0
    
    min_revenue = views_in_thousands * base_cpm_min * engagement_multiplier * channel_multiplier
    max_revenue = views_in_thousands * base_cpm_max * engagement_multiplier * channel_multiplier
    
    update_columns(
      estimated_revenue_min: min_revenue.round(2),
      estimated_revenue_max: max_revenue.round(2)
    )
  end

  def parse_duration(duration_string)
    return nil unless duration_string
    
    # Parse ISO 8601 duration format (PT1H2M3S)
    match = duration_string.match(/PT(?:(\d+)H)?(?:(\d+)M)?(?:(\d+)S)?/)
    return nil unless match
    
    hours = (match[1] || 0).to_i
    minutes = (match[2] || 0).to_i
    seconds = (match[3] || 0).to_i
    
    hours * 3600 + minutes * 60 + seconds
  end

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