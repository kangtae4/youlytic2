class ChannelAnalysisJob
  include Sidekiq::Job

  sidekiq_options retry: 3, backtrace: true

  def perform(analysis_report_id)
    analysis_report = AnalysisReport.find(analysis_report_id)
    
    Rails.logger.info "Starting analysis for report #{analysis_report_id}"
    
    begin
      analysis_report.complete_analysis!
      Rails.logger.info "Completed analysis for report #{analysis_report_id}"
    rescue => e
      Rails.logger.error "Analysis failed for report #{analysis_report_id}: #{e.message}"
      raise e
    end
  end
end