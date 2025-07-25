require 'google/apis/youtube_v3'
require 'net/http'
require 'json'

class YoutubeApiService
  include Google::Apis::YoutubeV3
  
  attr_reader :youtube, :api_key

  def initialize
    @api_key = ENV['YOUTUBE_API_KEY']
    raise 'YouTube API key not configured' unless @api_key
    
    @youtube = YouTubeService.new
    @youtube.key = @api_key
  end

  def fetch_channel_by_url(url)
    channel_id = extract_channel_id_from_url(url)
    return nil unless channel_id
    
    fetch_channel_by_id(channel_id)
  end

  def fetch_channel_by_id(channel_id)
    begin
      response = youtube.list_channels(
        'snippet,statistics,brandingSettings',
        id: channel_id
      )
      
      return nil if response.items.empty?
      
      channel_data = response.items.first
      process_channel_data(channel_data)
    rescue Google::Apis::Error => e
      Rails.logger.error "YouTube API error: #{e.message}"
      nil
    end
  end

  def fetch_channel_by_username(username)
    begin
      response = youtube.list_channels(
        'snippet,statistics,brandingSettings',
        for_username: username
      )
      
      return nil if response.items.empty?
      
      channel_data = response.items.first
      process_channel_data(channel_data)
    rescue Google::Apis::Error => e
      Rails.logger.error "YouTube API error: #{e.message}"
      nil
    end
  end

  def fetch_channel_by_handle(handle)
    begin
      response = youtube.list_channels(
        'snippet,statistics,brandingSettings',
        for_handle: handle
      )
      
      return nil if response.items.empty?
      
      channel_data = response.items.first
      process_channel_data(channel_data)
    rescue Google::Apis::Error => e
      Rails.logger.error "YouTube API error: #{e.message}"
      nil
    end
  end

  def search_channel_by_name(query)
    begin
      response = youtube.list_searches(
        'snippet',
        q: query,
        type: 'channel',
        max_results: 10
      )
      
      channels = response.items.map do |item|
        {
          channel_id: item.snippet.channel_id,
          title: item.snippet.title,
          description: item.snippet.description,
          thumbnail: item.snippet.thumbnails&.default&.url
        }
      end
      
      channels
    rescue Google::Apis::Error => e
      Rails.logger.error "YouTube API search error: #{e.message}"
      []
    end
  end

  def fetch_channel_videos(channel_id, max_results = 50)
    begin
      # Search for videos from the channel
      search_response = youtube.list_searches(
        'id',
        channel_id: channel_id,
        type: 'video',
        order: 'date',
        max_results: max_results
      )
      
      return [] if search_response.items.empty?
      
      video_ids = search_response.items.map(&:id).map(&:video_id)
      fetch_videos_details(video_ids)
    rescue Google::Apis::Error => e
      Rails.logger.error "YouTube API error fetching videos: #{e.message}"
      []
    end
  end

  def fetch_videos_details(video_ids)
    return [] if video_ids.empty?
    
    begin
      # YouTube API allows max 50 videos per request
      video_data = []
      
      video_ids.each_slice(50) do |batch_ids|
        response = youtube.list_videos(
          'snippet,statistics,contentDetails',
          id: batch_ids.join(',')
        )
        
        batch_data = response.items.map { |video| process_video_data(video) }
        video_data.concat(batch_data)
      end
      
      video_data
    rescue Google::Apis::Error => e
      Rails.logger.error "YouTube API error fetching video details: #{e.message}"
      []
    end
  end

  def fetch_video_categories
    begin
      response = youtube.list_video_categories(
        'snippet',
        region_code: 'US'
      )
      
      categories = response.items.map do |category|
        {
          id: category.id,
          title: category.snippet.title
        }
      end
      
      # Cache categories for 24 hours
      Rails.cache.write('youtube_categories', categories, expires_in: 24.hours)
      categories
    rescue Google::Apis::Error => e
      Rails.logger.error "YouTube API error fetching categories: #{e.message}"
      Rails.cache.read('youtube_categories') || []
    end
  end

  def get_quota_usage
    # This is an estimate based on API calls
    # Each call type has different quota costs
    {
      channels_list: 1,          # for_username, for_handle, id
      search_list: 100,          # search by name (expensive)
      videos_list: 1,
      video_categories_list: 1
    }
  end

  private

  def extract_channel_id_from_url(url)
    return url if url.match?(/^UC[a-zA-Z0-9_-]{22}$/)
    
    # Handle different YouTube URL formats
    patterns = [
      %r{youtube\.com/channel/([UC][a-zA-Z0-9_-]{22})},
      %r{youtube\.com/c/([^/?]+)},
      %r{youtube\.com/user/([^/?]+)},
      %r{youtube\.com/@([^/?]+)}
    ]
    
    patterns.each do |pattern|
      match = url.match(pattern)
      if match
        identifier = match[1]
        
        # If it's already a channel ID, return it
        return identifier if identifier.match?(/^UC[a-zA-Z0-9_-]{22}$/)
        
        # Otherwise, search for the channel
        channel = search_channel_by_identifier(identifier)
        return channel[:channel_id] if channel
      end
    end
    
    nil
  end

  def search_channel_by_identifier(identifier)
    # Try handle first (for @username format)
    channel_data = fetch_channel_by_handle(identifier)
    return { channel_id: channel_data[:id] } if channel_data
    
    # Try username
    channel_data = fetch_channel_by_username(identifier)
    return { channel_id: channel_data[:id] } if channel_data
    
    # Try searching by name as last resort
    results = search_channel_by_name(identifier)
    return results.first if results.any?
    
    nil
  end

  def process_channel_data(channel_data)
    {
      id: channel_data.id,
      snippet: {
        title: channel_data.snippet.title,
        description: channel_data.snippet.description,
        thumbnails: channel_data.snippet.thumbnails&.to_h,
        country: channel_data.snippet.country,
        defaultLanguage: channel_data.snippet.default_language,
        publishedAt: channel_data.snippet.published_at
      },
      statistics: {
        subscriberCount: channel_data.statistics.subscriber_count,
        videoCount: channel_data.statistics.video_count,
        viewCount: channel_data.statistics.view_count
      },
      brandingSettings: channel_data.branding_settings&.to_h || {}
    }
  end

  def process_video_data(video_data)
    {
      id: video_data.id,
      snippet: {
        title: video_data.snippet.title,
        description: video_data.snippet.description,
        thumbnails: video_data.snippet.thumbnails&.to_h,
        publishedAt: video_data.snippet.published_at,
        categoryId: video_data.snippet.category_id,
        defaultLanguage: video_data.snippet.default_language
      },
      statistics: {
        viewCount: video_data.statistics.view_count,
        likeCount: video_data.statistics.like_count,
        commentCount: video_data.statistics.comment_count
      },
      contentDetails: {
        duration: video_data.content_details.duration
      }
    }
  end
end