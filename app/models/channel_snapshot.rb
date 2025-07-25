class ChannelSnapshot < ApplicationRecord
  belongs_to :channel

  validates :snapshot_date, presence: true, uniqueness: { scope: :channel_id }

  scope :recent, -> { order(snapshot_date: :desc) }
  scope :for_period, ->(start_date, end_date) { where(snapshot_date: start_date..end_date) }

  def growth_from_previous
    previous_snapshot = channel.channel_snapshots
                              .where('snapshot_date < ?', snapshot_date)
                              .order(snapshot_date: :desc)
                              .first
    
    return {} unless previous_snapshot
    
    {
      subscriber_growth: subscriber_count - previous_snapshot.subscriber_count,
      video_growth: video_count - previous_snapshot.video_count,
      view_growth: view_count - previous_snapshot.view_count,
      days_between: (snapshot_date - previous_snapshot.snapshot_date).to_i
    }
  end

  def daily_growth_rate
    growth = growth_from_previous
    return {} if growth.empty? || growth[:days_between].zero?
    
    {
      daily_subscriber_growth: (growth[:subscriber_growth].to_f / growth[:days_between]).round(2),
      daily_video_growth: (growth[:video_growth].to_f / growth[:days_between]).round(2),
      daily_view_growth: (growth[:view_growth].to_f / growth[:days_between]).round(2)
    }
  end

  def self.create_for_channel!(channel)
    create!(
      channel: channel,
      snapshot_date: Date.current,
      subscriber_count: channel.subscriber_count,
      video_count: channel.video_count,
      view_count: channel.view_count,
      videos_published_count: channel.videos.where(published_at: Date.current.all_day).count
    )
  end
end