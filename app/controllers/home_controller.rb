class HomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]

  def index
    @recent_analyses = AnalysisReport.includes(:channel)
                                   .where(status: 'completed')
                                   .order(created_at: :desc)
                                   .limit(6)
    
    @popular_channels = Channel.popular.limit(8)
    @total_analyses = AnalysisReport.where(status: 'completed').count
    @user_quota = current_user&.remaining_quota
  end
end