require 'test_helper'

class UsersProfileTest < ActionDispatch::IntegrationTest
  include ApplicationHelper

  def setup
    @user = users(:michael)
  end

  test "profile display" do
    get user_path(@user)
    assert_template 'users/show'
    assert_select 'title', full_title(@user.name)
    assert_select 'h1', text: @user.name
    # h1直下の子要素にimg.gravatarがあること
    assert_select 'h1>img.gravatar'
    # micropostsの数が正しく表示されていること
    assert_match @user.microposts.count.to_s, response.body
    assert_select 'div.pagination'
    # paginateで返されるmicropostsが、表示されたページと一致していること
    @user.microposts.paginate(page: 1).each do |micropost|
      assert_match micropost.content, response.body
    end

    # Stats（フォロー・フォロワー数）表示のテスト
    # フォロー・フォロワーページヘのリンクがあること
    assert_select "a[href=?]", following_user_path(@user)
    assert_select "a[href=?]", followers_user_path(@user)
    # #following, #followers要素内のテキストにフォロー・フォロワー数が含まれていること
    assert_select "#following", @user.following.count.to_s
    assert_select "#followers", @user.followers.count.to_s
  end
end
