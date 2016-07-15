require 'test_helper'

class StatsTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    log_in_as(@user)
  end

  def stats_test(user)
    # Stats（フォロー・フォロワー数）表示のテスト
    # フォロー・フォロワーページヘのリンクがあること
    assert_select "a[href=?]", following_user_path(user)
    assert_select "a[href=?]", followers_user_path(user)
    # #following, #followers要素内のテキストにフォロー・フォロワー数が含まれていること
    assert_select "#following", user.following.count.to_s
    assert_select "#followers", user.followers.count.to_s
  end

  # プロフィールページ
  test "Stats on Profile page" do
    get user_path(@user)
    stats_test(@user)
  end
  # ホームページ
  test "Stats on Home page" do
    get root_path
    stats_test(@user)
  end
end
