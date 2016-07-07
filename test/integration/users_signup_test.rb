require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  def setup
    # deliveries(送信したメールの配列)はグローバルなので、毎回クリアする
    ActionMailer::Base.deliveries.clear
  end

  test "invalid signup information" do
    get signup_path
    # ブロックの実行前と後で、`User.count`の値が変わらないことをテストする
    assert_no_difference 'User.count' do
      # users_pathにPOSTリクエスト→createアクション
      post users_path, user: { name:  "",
                               email: "user@invalid",
                               password:              "foo",
                               password_confirmation: "bar" }
    end
    # サインアップが失敗したとき、再度`users/new`がレンダリングされることをテスト
    assert_template 'users/new'
  end

  test "valid signup information with account activation" do
    get signup_path
    # ブロックの実行前と後で、`User.count`の値が+1違うこと
    assert_difference 'User.count', 1 do
      post users_path, user: { name:  "Example User",
                               email: "user@example.com",
                               password:              "password",
                               password_confirmation: "password" }
    end
    # メールが送信されていること
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert_not user.activated?
    # Try to log in before activation.
    # アクティベートする前はログインできないこと
    log_in_as(user)
    assert_not is_logged_in?
    # Invalid activation token
    # 不正なトークンを渡してもアクティベートできないこと
    get edit_account_activation_path("invalid token", email: user.email)
    assert_not is_logged_in?
    # Valid token, wrong email
    # トークンは正しいがメールアドレスが間違っていたときもアクティベートできないこと
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert_not is_logged_in?
    # Valid activation token
    # 正しいトークン・メールアドレスであればアクティベートしてログインできること
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
