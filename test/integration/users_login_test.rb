require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
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
end
