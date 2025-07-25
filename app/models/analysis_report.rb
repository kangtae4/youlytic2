class AnalysisReport < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :channel

  enum status: { pending: 'pending', processing: 'processing', completed: 'completed', failed: 'failed' }

  validates :status, presence: true
  validates :permalink_token, uniqueness: true, allow_nil: true

  scope :recent, -> { order(created_at: :desc) }
  scope :public_accessible, -> { where('permalink_expires_at > ?', Time.current) }

  before_create :generate_permalink_token

  def generate_summary_metrics!
    return unless channel && channel.videos.any?

    videos = channel.videos.recent.limit(50)
    
    metrics = {
      total_videos_analyzed: videos.count,
      average_views: videos.average(:view_count)&.round || 0,
      median_views: calculate_median(videos.pluck(:view_count)),
      average_engagement_rate: videos.average(:engagement_rate)&.round(2) || 0,
      total_estimated_revenue_min: videos.sum(:estimated_revenue_min),
      total_estimated_revenue_max: videos.sum(:estimated_revenue_max),
      
      # Performance distribution
      high_performers: videos.where('view_count > ?', videos.average(:view_count) * 1.5).count,
      low_performers: videos.where('view_count < ?', videos.average(:view_count) * 0.5).count,
      
      # Content patterns
      average_duration: videos.average(:duration_seconds)&.round || 0,
      upload_frequency: calculate_upload_frequency(videos),
      
      # Top performing videos
      top_videos: videos.order(view_count: :desc).limit(10).pluck(:id, :title, :view_count),
      
      generated_at: Time.current
    }

    update!(summary_metrics: metrics)
  end

  def generate_revenue_analysis!
    return unless channel

    total_revenue_min = channel.videos.sum(:estimated_revenue_min)
    total_revenue_max = channel.videos.sum(:estimated_revenue_max)
    
    monthly_revenue_min = total_revenue_min / 12
    monthly_revenue_max = total_revenue_max / 12
    
    analysis = {
      estimated_annual_revenue: {
        min: total_revenue_min.round(2),
        max: total_revenue_max.round(2)
      },
      estimated_monthly_revenue: {
        min: monthly_revenue_min.round(2),
        max: monthly_revenue_max.round(2)
      },
      revenue_per_video: {
        min: channel.video_count > 0 ? (total_revenue_min / channel.video_count).round(2) : 0,
        max: channel.video_count > 0 ? (total_revenue_max / channel.video_count).round(2) : 0
      },
      rpm: {
        min: channel.view_count > 0 ? (total_revenue_min / channel.view_count * 1000).round(2) : 0,
        max: channel.view_count > 0 ? (total_revenue_max / channel.view_count * 1000).round(2) : 0
      },
      revenue_breakdown: calculate_revenue_breakdown,
      generated_at: Time.current
    }

    update!(revenue_analysis: analysis)
  end

  def generate_content_analysis!
    return unless channel && channel.videos.any?

    videos = channel.videos.recent.limit(100)
    
    analysis = {
      upload_patterns: {
        videos_per_month: calculate_videos_per_month(videos),
        most_active_day: calculate_most_active_day(videos),
        average_gap_between_uploads: calculate_upload_gap(videos)
      },
      content_performance: {
        best_performing_length: calculate_best_length(videos),
        engagement_by_length: calculate_engagement_by_length(videos),
        performance_trends: calculate_performance_trends(videos)
      },
      audience_insights: {
        peak_engagement_time: calculate_peak_engagement(videos),
        content_consistency: calculate_consistency_score(videos)
      },
      generated_at: Time.current
    }

    update!(content_analysis: analysis)
  end

  def complete_analysis!
    mark_as_processing!
    
    self.started_at = Time.current
    
    begin
      generate_summary_metrics!
      generate_revenue_analysis!
      generate_content_analysis!
      
      self.completed_at = Time.current
      self.processing_duration_seconds = (completed_at - started_at).to_i
      
      mark_as_completed!
    rescue => e
      self.error_message = e.message
      mark_as_failed!
      raise
    end
  end

  def permalink_active?
    permalink_expires_at.present? && permalink_expires_at > Time.current
  end

  def extend_permalink!(hours = 24)
    update!(permalink_expires_at: hours.hours.from_now)
  end

  private

  def generate_permalink_token
    self.permalink_token = SecureRandom.urlsafe_base64(16)
    self.permalink_expires_at = 24.hours.from_now
  end

  def calculate_median(values)
    return 0 if values.empty?
    sorted = values.sort
    middle = sorted.length / 2
    sorted.length.odd? ? sorted[middle] : (sorted[middle - 1] + sorted[middle]) / 2.0
  end

  def calculate_upload_frequency(videos)
    return 0 if videos.count < 2
    
    first_video = videos.order(:published_at).first
    last_video = videos.order(:published_at).last
    
    return 0 unless first_video&.published_at && last_video&.published_at
    
    days_between = (last_video.published_at - first_video.published_at) / 1.day
    return 0 if days_between.zero?
    
    (videos.count.to_f / days_between).round(2)
  end

  def calculate_revenue_breakdown
    videos = channel.videos.includes(:channel)
    
    breakdown = videos.group_by { |v| v.view_count / 100_000 }.transform_values do |group_videos|
      {
        count: group_videos.count,
        revenue_min: group_videos.sum(&:estimated_revenue_min),
        revenue_max: group_videos.sum(&:estimated_revenue_max)
      }
    end
    
    breakdown.sort.to_h
  end

  def calculate_videos_per_month(videos)
    return 0 if videos.empty?
    
    months = videos.group_by { |v| v.published_at&.beginning_of_month }.count
    return 0 if months.zero?
    
    (videos.count.to_f / months).round(1)
  end

  def calculate_most_active_day(videos)
    return nil if videos.empty?
    
    day_counts = videos.group_by { |v| v.published_at&.strftime('%A') }.transform_values(&:count)
    day_counts.max_by { |_, count| count }&.first
  end

  def calculate_upload_gap(videos)
    return 0 if videos.count < 2
    
    sorted_videos = videos.sort_by(&:published_at)
    gaps = []
    
    sorted_videos.each_cons(2) do |prev, current|
      next unless prev.published_at && current.published_at
      gaps << (current.published_at - prev.published_at) / 1.day
    end
    
    return 0 if gaps.empty?
    gaps.sum / gaps.count
  end

  def calculate_best_length(videos)
    return nil if videos.empty?
    
    length_performance = videos.group_by { |v| categorize_length(v.duration_seconds) }
                              .transform_values { |group| group.sum(&:view_count) / group.count }
    
    length_performance.max_by { |_, avg_views| avg_views }&.first
  end

  def calculate_engagement_by_length(videos)
    videos.group_by { |v| categorize_length(v.duration_seconds) }
          .transform_values { |group| group.sum(&:engagement_rate) / group.count }
  end

  def calculate_performance_trends(videos)
    monthly_performance = videos.group_by { |v| v.published_at&.beginning_of_month }
                               .transform_values { |group| group.sum(&:view_count) / group.count }
    
    monthly_performance.sort.to_h
  end

  def calculate_peak_engagement(videos)
    hour_engagement = videos.group_by { |v| v.published_at&.hour }
                           .transform_values { |group| group.sum(&:engagement_rate) / group.count }
    
    hour_engagement.max_by { |_, engagement| engagement }&.first
  end

  def calculate_consistency_score(videos)
    return 0 if videos.empty?
    
    view_counts = videos.pluck(:view_count)
    mean = view_counts.sum.to_f / view_counts.count
    variance = view_counts.sum { |v| (v - mean) ** 2 } / view_counts.count
    std_dev = Math.sqrt(variance)
    
    # Lower coefficient of variation = higher consistency
    coefficient_of_variation = std_dev / mean
    [(1 - coefficient_of_variation) * 100, 0].max.round(1)
  end

  def categorize_length(duration_seconds)
    return 'Unknown' if duration_seconds.nil?
    
    case duration_seconds
    when 0..300
      'Short (0-5 min)'
    when 301..600
      'Medium (5-10 min)'
    when 601..1200
      'Long (10-20 min)'
    else
      'Very Long (20+ min)'
    end
  end
end