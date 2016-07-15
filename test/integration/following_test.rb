require 'test_helper'

class FollowingTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
    @other = users(:archer)
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

  test "should follow a user the standard way" do
    # 通常のpostリクエストでフォローが増えること
    assert_difference '@user.following.count', 1 do
      post relationships_path, followed_id: @other.id
    end
  end

  test "should follow a user with Ajax" do
    # Ajax経由のpostリクエストでフォローが増えること
    # xhrメソッドでAjaxリクエスト(XmlHttpRequest)を送れる
    assert_difference '@user.following.count', 1 do
      xhr :post, relationships_path, followed_id: @other.id
    end
  end

  test "should unfollow a user the standard way" do
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    # 通常のdeleteリクエストでフォローを外せること
    assert_difference '@user.following.count', -1 do
      delete relationship_path(relationship)
    end
  end

  test "should unfollow a user with Ajax" do
    @user.follow(@other)
    relationship = @user.active_relationships.find_by(followed_id: @other.id)
    # Ajax経由のdeleteリクエストでフォローを外せること
    assert_difference '@user.following.count', -1 do
      xhr :delete, relationship_path(relationship)
    end
  end

  # ホームページのフィード表示テスト
  test "feed on Home page" do
    get root_path
    # フィード1ページ目の投稿内容がすべてレスポンスに含まれていること
    @user.feed.paginate(page: 1).each do |micropost|
      assert_match CGI.escapeHTML(micropost.content), response.body
    end
  end
end
