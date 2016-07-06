class AccountActivationsController < ApplicationController
  def edit
    user = User.find_by(email: params[:email])
    # ユーザーが存在し、アクティベートされておらず、トークンが正しければ
    if user && !user.activated? && user.authenticated?(:activation, params[:id])
      # アクティベート処理を実行
      user.update_attribute(:activated,    true)
      user.update_attribute(:activated_at, Time.zone.now)
      # ログインしてリダイレクト
      log_in user
      flash[:success] = "Account activated!"
      redirect_to user
    else
      flash[:danger] = "Invalid activation link"
      redirect_to root_url
    end
  end
end
