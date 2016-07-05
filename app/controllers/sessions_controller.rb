class SessionsController < ApplicationController
  def new
  end

  def create
    # `find_by(email:)`でメールアドレスからユーザーを検索
    user = User.find_by(email: params[:session][:email].downcase)
    # ユーザーが存在し、かつパスワードが正しければ認証OK
    if user && user.authenticate(params[:session][:password])
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user)
      # アクセスしようとしていたURLがあればそこへ、なければプロフィールページにリダイレクト
      redirect_back_or user
    else
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
