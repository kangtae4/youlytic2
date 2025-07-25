class AnalysisReportsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:public_show]
  before_action :check_analysis_quota, only: [:create]
  before_action :set_analysis_report, only: [:show, :pdf, :csv, :extend_permalink]
  before_action :set_public_analysis_report, only: [:public_show]

  def show
    @channel = @analysis_report.channel
    @videos = @channel.videos.includes(:channel).order(view_count: :desc).limit(20)
  end

  def public_show
    unless @analysis_report.permalink_active?
      render 'expired_permalink', status: :gone
      return
    end

    @channel = @analysis_report.channel
    @videos = @channel.videos.includes(:channel).order(view_count: :desc).limit(20)
    render 'show'
  end

  def create
    channel_input = params[:channel_input]
    
    if channel_input.blank?
      flash[:alert] = "채널 URL 또는 ID를 입력해주세요."
      redirect_to root_path
      return
    end

    begin
      @analysis_report = ChannelAnalyzerService.analyze_async(channel_input, current_user)
      redirect_to analysis_report_path(@analysis_report), 
                  notice: "분석이 시작되었습니다. 잠시만 기다려주세요."
    rescue => e
      Rails.logger.error "Analysis creation error: #{e.message}"
      flash[:alert] = "분석 중 오류가 발생했습니다: #{e.message}"
      redirect_to root_path
    end
  end

  def pdf
    respond_to do |format|
      format.pdf do
        pdf_html = render_to_string(
          template: 'analysis_reports/pdf_report',
          layout: 'pdf',
          locals: { analysis_report: @analysis_report, channel: @analysis_report.channel }
        )
        
        pdf = WickedPdf.new.pdf_from_string(pdf_html)
        
        @analysis_report.increment!(:pdf_downloads)
        
        send_data pdf,
                  filename: "#{@analysis_report.channel.title}_analysis.pdf",
                  type: 'application/pdf',
                  disposition: 'attachment'
      end
    end
  end

  def csv
    respond_to do |format|
      format.csv do
        csv_data = generate_csv_data(@analysis_report)
        
        @analysis_report.increment!(:csv_exports)
        
        send_data csv_data,
                  filename: "#{@analysis_report.channel.title}_data.csv",
                  type: 'text/csv',
                  disposition: 'attachment'
      end
    end
  end

  def extend_permalink
    @analysis_report.extend_permalink!(24)
    
    respond_to do |format|
      format.json { render json: { success: true, new_expiry: @analysis_report.permalink_expires_at } }
      format.html { redirect_back(fallback_location: analysis_report_path(@analysis_report)) }
    end
  end

  private

  def set_analysis_report
    @analysis_report = current_user&.analysis_reports&.find(params[:id]) ||
                      AnalysisReport.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    flash[:alert] = "분석 리포트를 찾을 수 없습니다."
    redirect_to root_path
  end

  def set_public_analysis_report
    @analysis_report = AnalysisReport.find_by!(permalink_token: params[:permalink_token])
  rescue ActiveRecord::RecordNotFound
    render 'expired_permalink', status: :not_found
  end

  def generate_csv_data(analysis_report)
    require 'csv'
    
    CSV.generate(headers: true) do |csv|
      # Header
      csv << ['Video Title', 'Published Date', 'Views', 'Likes', 'Comments', 'Duration', 'Engagement Rate', 'Estimated Revenue Min', 'Estimated Revenue Max']
      
      # Video data
      analysis_report.channel.videos.order(published_at: :desc).each do |video|
        csv << [
          video.title,
          video.published_at&.strftime('%Y-%m-%d'),
          video.view_count,
          video.like_count,
          video.comment_count,
          video.duration_formatted,
          video.engagement_rate,
          video.estimated_revenue_min,
          video.estimated_revenue_max
        ]
      end
    end
  end
end