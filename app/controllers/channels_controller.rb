class ChannelsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:show, :search]

  def show
    @channel = Channel.find(params[:id])
    @videos = @channel.videos.includes(:channel)
                             .order(published_at: :desc)
                             .page(params[:page])
                             .per(20)
    
    @recent_analysis = @channel.analysis_reports
                              .where(status: 'completed')
                              .order(created_at: :desc)
                              .first
  end

  def search
    query = params[:q]
    
    if query.present?
      begin
        youtube_api = YoutubeApiService.new
        @search_results = youtube_api.search_channel_by_name(query)
      rescue => e
        Rails.logger.error "Channel search error: #{e.message}"
        @search_results = []
        flash.now[:alert] = "검색 중 오류가 발생했습니다. 다시 시도해주세요."
      end
    else
      @search_results = []
    end

    render json: @search_results
  end
end