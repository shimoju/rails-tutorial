class MicropostsController < ApplicationController
  before_action :logged_in_user, only: [:create, :destroy]
  before_action :correct_user, only: :destroy

  def create
    # 現在のユーザーに関連付けられたmicropostを作成
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to root_url
    else
      # renderで再描画したときに@feed_items変数がなくなってしまうため、空の配列を用意する
      @feed_items = []
      # 投稿フォームはホームページ(root)に設置する
      render 'static_pages/home'
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    # リファラ（直前に閲覧していたページ）があればそこへ、なければrootにリダイレクト
    redirect_to request.referrer || root_url
  end

  private

    def micropost_params
      params.require(:micropost).permit(:content)
    end

    def correct_user
      # ログイン中のユーザーのmicropostであるかを確認する
      @micropost = current_user.microposts.find_by(id: params[:id])
      redirect_to root_url if @micropost.nil?
    end
end
