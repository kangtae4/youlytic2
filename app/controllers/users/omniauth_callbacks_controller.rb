class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  def google_oauth2
    @user = User.from_omniauth(request.env["omniauth.auth"])
    handle_oauth_callback("Google")
  end

  def kakao
    @user = User.from_omniauth(request.env["omniauth.auth"])
    handle_oauth_callback("Kakao")
  end

  def naver
    @user = User.from_omniauth(request.env["omniauth.auth"])
    handle_oauth_callback("Naver")
  end

  def failure
    redirect_to new_user_session_path, alert: "로그인에 실패했습니다."
  end

  private

  def handle_oauth_callback(provider_name)
    if @user.persisted?
      sign_in_and_redirect @user, event: :authentication
      set_flash_message(:notice, :success, kind: provider_name) if is_navigational_format?
    else
      session["devise.#{provider_name.downcase}_data"] = request.env["omniauth.auth"].except(:extra)
      redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
    end
  end
end