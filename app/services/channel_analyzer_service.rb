class ChannelAnalyzerService
  attr_reader :youtube_api, :channel, :analysis_report

  def initialize(channel_url_or_id, user = nil)
    @youtube_api = YoutubeApiService.new
    @channel_url_or_id = channel_url_or_id
    @user = user
  end

  def analyze!
    # Create or find the analysis report
    @analysis_report = create_analysis_report
    
    begin
      # Step 1: Fetch channel data
      channel_data = fetch_channel_data
      raise "Channel not found" unless channel_data
      
      # Step 2: Create or update channel record
      @channel = create_or_update_channel(channel_data)
      
      # Step 3: Fetch and store videos
      videos_data = fetch_videos_data
      create_or_update_videos(videos_data)
      
      # Step 4: Create channel snapshot
      @channel.create_snapshot!
      
      # Step 5: Complete analysis in background
      ChannelAnalysisJob.perform_async(@analysis_report.id)
      
      @analysis_report
    rescue => e
      @analysis_report.update!(
        status: 'failed',
        error_message: e.message
      )
      Rails.logger.error "Channel analysis failed: #{e.message}"
      raise e
    end
  end

  def self.analyze_async(channel_url_or_id, user = nil)
    analyzer = new(channel_url_or_id, user)
    analyzer.analyze!
  end

  private

  def create_analysis_report
    report = AnalysisReport.create!(
      user: @user,
      status: 'pending'
    )
    
    # Update user's API usage if applicable
    @user&.increment_api_usage!
    
    report
  end

  def fetch_channel_data
    # Try different methods to get channel data
    if @channel_url_or_id.include?('youtube.com') || @channel_url_or_id.include?('youtu.be')
      @youtube_api.fetch_channel_by_url(@channel_url_or_id)
    elsif @channel_url_or_id.match?(/^UC[a-zA-Z0-9_-]{22}$/)
      @youtube_api.fetch_channel_by_id(@channel_url_or_id)
    else
      # Try as username first, then as search query
      channel_data = @youtube_api.fetch_channel_by_username(@channel_url_or_id)
      return channel_data if channel_data
      
      # Search by name and take the first result
      search_results = @youtube_api.search_channel_by_name(@channel_url_or_id)
      if search_results.any?
        first_result = search_results.first
        @youtube_api.fetch_channel_by_id(first_result[:channel_id])
      else
        nil
      end
    end
  end

  def create_or_update_channel(channel_data)
    channel = Channel.find_or_initialize_by(youtube_id: channel_data[:id])
    channel.update_from_youtube_data!(channel_data)
    
    # Update analysis report with channel reference
    @analysis_report.update!(channel: channel)
    
    channel
  end

  def fetch_videos_data
    return [] unless @channel
    
    video_limit = Rails.application.config.x.default_video_fetch_limit
    @youtube_api.fetch_channel_videos(@channel.youtube_id, video_limit)
  end

  def create_or_update_videos(videos_data)
    return if videos_data.empty?
    
    videos_data.each do |video_data|
      video = Video.find_or_initialize_by(
        youtube_id: video_data[:id],
        channel: @channel
      )
      
      video.update_from_youtube_data!(video_data)
    end
    
    Rails.logger.info "Updated #{videos_data.count} videos for channel #{@channel.title}"
  end
end