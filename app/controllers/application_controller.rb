class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  
  before_action :authenticate_user!, except: [:health]
  before_action :configure_permitted_parameters, if: :devise_controller?

  def health
    render json: { status: 'ok', timestamp: Time.current }
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:first_name, :last_name])
    devise_parameter_sanitizer.permit(:account_update, keys: [:first_name, :last_name])
  end

  def check_analysis_quota
    unless current_user&.can_analyze?
      flash[:alert] = "일일 분석 할당량을 초과했습니다. 프리미엄으로 업그레이드하거나 내일 다시 시도해주세요."
      redirect_to root_path
    end
  end
end