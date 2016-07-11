require 'test_helper'

class UsersIndexTest < ActionDispatch::IntegrationTest
  def setup
    @admin     = users(:michael)
    @non_admin = users(:archer)
  end

  # ページネーションと削除リンクのテスト
  test "index as admin including pagination and delete links" do
    log_in_as(@admin)
    # ユーザー一覧ページにアクセス
    get users_path
    assert_template 'users/index'
    assert_select 'div.pagination'
    # `User.paginate`で返されるユーザーが、表示されたページと一致していること
    first_page_of_users = User.where(activated: true).paginate(page: 1)
    first_page_of_users.each do |user|
      assert_select 'a[href=?]', user_path(user), text: user.name
      # 本人のアカウント以外には削除リンクが表示されること
      unless user == @admin
        assert_select 'a[href=?]', user_path(user), text: 'delete'
      end
    end
    # adminはユーザーを削除できること
    assert_difference 'User.count', -1 do
      delete user_path(@non_admin)
    end
  end

  # adminではない場合、ユーザー削除リンクが表示されないこと
  test "index as non-admin" do
    log_in_as(@non_admin)
    get users_path
    assert_select 'a', text: 'delete', count: 0
  end
end
