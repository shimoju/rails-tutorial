require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  # メールアドレス/パスワードが正しくないとき
  test "login with invalid information" do
    get login_path
    assert_template 'sessions/new'
    post login_path, session: { email: "", password: "" }
    # ログインフォームが表示され、エラーメッセージ(flash)が存在すること
    assert_template 'sessions/new'
    assert_not flash.empty?
    # 別のページにアクセスするとエラーメッセージが消えていること
    get root_path
    assert flash.empty?
  end

  test "login with valid information followed by logout" do
    get login_path
    post login_path, session: { email: @user.email, password: 'password' }
    assert is_logged_in?
    # ログインできたらプロフィールページにリダイレクトすること
    assert_redirected_to @user
    # リダイレクトを追う（実際にリダイレクト先ページにアクセスする）
    follow_redirect!
    assert_template 'users/show'
    # ログインページヘのリンクが存在しない(リンクが0個)こと
    assert_select "a[href=?]", login_path, count: 0
    assert_select "a[href=?]", logout_path
    assert_select "a[href=?]", user_path(@user)

    # logout_pathにDELETEリクエスト→destroyアクション
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    # Simulate a user clicking logout in a second window.
    delete logout_path
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end

  test "login with remembering" do
    log_in_as(@user, remember_me: '1')
    # テスト内ではキーにシンボルが使えないので、文字列でアクセスする
    assert_not_nil cookies['remember_token']
  end

  test "login without remembering" do
    log_in_as(@user, remember_me: '0')
    assert_nil cookies['remember_token']
  end
end
