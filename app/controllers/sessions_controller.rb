class SessionsController < ApplicationController
  def new
  end

  def create
    # `find_by(email:)`でメールアドレスからユーザーを検索
    user = User.find_by(email: params[:session][:email].downcase)
    # ユーザーが存在し、かつパスワードが正しければ認証OK
    if user && user.authenticate(params[:session][:password])
      # Log the user in and redirect to the user's show page.
    else
      # Create an error message.
      render 'new'
    end
  end

  def destroy
  end
end
