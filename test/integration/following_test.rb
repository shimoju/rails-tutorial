require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    log_in_as(@user)
  end

  test "following page" do
    get following_user_path(@user)
    assert_not @user.following.empty?
    # フォロー数がレスポンスに含まれていること
    assert_match @user.following.count.to_s, response.body
    # フォローしているユーザーへのリンクがすべて含まれていること
    @user.following.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end

  # followingと同様のテスト
  test "followers page" do
    get followers_user_path(@user)
    assert_not @user.followers.empty?
    assert_match @user.followers.count.to_s, response.body
    @user.followers.each do |user|
      assert_select "a[href=?]", user_path(user)
    end
  end
end
