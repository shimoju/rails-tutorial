require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password resets" do
    # 1. メールアドレスを入力してリセットメールを送信
    get new_password_reset_path
    assert_template 'password_resets/new'
    # Invalid email
    # メールアドレスが正しくないときは、flashを表示して再描画すること
    post password_resets_path, password_reset: { email: "" }
    assert_not flash.empty?
    assert_template 'password_resets/new'
    # Valid email
    # メールアドレスが正しいときは、トークンをセットしてリセットメールを送信すること
    post password_resets_path, password_reset: { email: @user.email }
    assert_not_equal @user.reset_digest, @user.reload.reset_digest
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url

    # 2. ユーザー情報の検証（メールアドレス・トークン・アクティベーション）
    # Password reset form
    user = assigns(:user)
    # Wrong email
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url
    # Inactive user
    user.toggle!(:activated)
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)
    # Right email, wrong token
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url
    # Right email, right token
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    # hiddenフォームにユーザーのメールアドレスが入っていること
    # <input id="email" name="email" type="hidden" value="michael@example.com" />
    assert_select "input[name=email][type=hidden][value=?]", user.email

    # 3. 新しいパスワードを入力してpostする
    # Invalid password & confirmation
    patch password_reset_path(user.reset_token),
          email: user.email,
          user: { password:              "foobaz",
                  password_confirmation: "barquux" }
    assert_select 'div#error_explanation'
    # Empty password
    patch password_reset_path(user.reset_token),
          email: user.email,
          user: { password:              "",
                  password_confirmation: "" }
    assert_select 'div#error_explanation'
    # Valid password & confirmation
    patch password_reset_path(user.reset_token),
          email: user.email,
          user: { password:              "foobaz",
                  password_confirmation: "foobaz" }
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end

  test "expired token" do
    get new_password_reset_path
    post password_resets_path, password_reset: { email: @user.email }

    @user = assigns(:user)
    # リセットメール送信時刻を3時間前にセット（期限切れは2時間）
    @user.update_attribute(:reset_sent_at, 3.hours.ago)
    patch password_reset_path(@user.reset_token),
          email: @user.email,
          user: { password:              "foobar",
                  password_confirmation: "foobar" }
    assert_response :redirect
    follow_redirect!
    # レスポンスボディ(ページのHTML)に"expired"が含まれていること
    assert_match /expired/i, response.body
  end
end
