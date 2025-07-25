class DashboardController < ApplicationController
  def index
    @recent_reports = current_user.analysis_reports
                                 .includes(:channel)
                                 .order(created_at: :desc)
                                 .limit(10)
    
    @analyzed_channels = current_user.analyzed_channels
                                   .includes(:analysis_reports)
                                   .order('analysis_reports.created_at DESC')
                                   .limit(8)
    
    @usage_stats = {
      total_analyses: current_user.analysis_reports.count,
      completed_analyses: current_user.analysis_reports.where(status: 'completed').count,
      remaining_quota: current_user.remaining_quota,
      this_month_analyses: current_user.analysis_reports.where(created_at: 1.month.ago..Time.current).count
    }
  end

  def history
    @reports = current_user.analysis_reports
                          .includes(:channel)
                          .order(created_at: :desc)
                          .page(params[:page])
                          .per(20)
  end

  def favorites
    # This would require a favorites model/relationship
    # For now, show most analyzed channels
    @favorite_channels_data = current_user.analysis_reports
                                         .joins(:channel)
                                         .group('channels.id, channels.title, channels.thumbnail_url, channels.subscriber_count')
                                         .order('COUNT(analysis_reports.id) DESC')
                                         .limit(20)
                                         .count
  end
end