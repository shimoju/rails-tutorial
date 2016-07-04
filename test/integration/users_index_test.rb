require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "index including pagination" do
    log_in_as(@user)
    # ユーザー一覧ページにアクセス
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    # `User.paginate`で返されるユーザーが、表示されたページと一致していること
    User.paginate(page: 1).each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
    end
  end
end
