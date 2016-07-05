require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "unsuccessful edit" do
    log_in_as(@user)
    get edit_user_path(@user)
    assert_template 'users/edit'
    # user_pathにPATCHリクエスト→編集
    patch user_path(@user), user: { name:  "",
                                    email: "foo@invalid",
                                    password:              "foo",
                                    password_confirmation: "bar" }
    assert_template 'users/edit'
  end

  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    # session[:forwarding_url]に転送先のURLが正しく入っていること
    assert_equal edit_user_url(@user), session[:forwarding_url]
    log_in_as(@user)
    # ログイン前にアクセスしようとしていたページ(edit_user_path)にリダイレクトされること
    assert_redirected_to edit_user_path(@user)
    # session[:forwarding_url]が削除されていること
    assert_nil session[:forwarding_url]
    name  = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user), user: { name:  name,
                                    email: email,
                                    password:              "",
                                    password_confirmation: "" }
    assert_not flash.empty?
    assert_redirected_to @user
    # @userをDBから読み込み直し、DBの値が確実に更新されていることを確認
    @user.reload
    assert_equal name,  @user.name
    assert_equal email, @user.email
  end
end
