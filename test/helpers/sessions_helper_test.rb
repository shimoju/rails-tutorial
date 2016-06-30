require 'test_helper'

class SessionsHelperTest < ActionView::TestCase
  def setup
    # fixturesからユーザーmichaelさんを作成
    @user = users(:michael)
    # rememberメソッドで覚える
    remember(@user)
  end

  # current_userメソッドで返ってくるユーザーが@userと一致していること
  test "current_user returns right user when session is nil" do
    assert_equal @user, current_user
    assert is_logged_in?
  end

  test "current_user returns nil when remember digest is wrong" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
end
