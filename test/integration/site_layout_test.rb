require 'test_helper'

class SiteLayoutTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "layout links" do
    get root_path
    assert_template 'static_pages/home'
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
  end

  # ログイン・ログアウトで変わるリンクのテスト
  # ログインしていないとき
  test "layout links for non-logged-in users" do
    get root_path
    # 表示するもの
    assert_select "a[href=?]", login_path
    # 表示しないもの
    assert_select "a[href=?]", users_path, count: 0 # ユーザー一覧
    assert_select "a[href=?]", user_path(@user), count: 0 # プロフィール
    assert_select "a[href=?]", edit_user_path(@user), count: 0 # 設定
    assert_select "a[href=?]", logout_path, count: 0 # ログアウト
  end

  # ログインしているとき
  test "layout links for logged-in users" do
    log_in_as(@user)
    get root_path
    # 表示するもの
    assert_select "a[href=?]", users_path # ユーザー一覧
    assert_select "a[href=?]", user_path(@user) # プロフィール
    assert_select "a[href=?]", edit_user_path(@user) # 設定
    assert_select "a[href=?]", logout_path # ログアウト
    # 表示しないもの
    assert_select "a[href=?]", login_path, count: 0
  end
end
