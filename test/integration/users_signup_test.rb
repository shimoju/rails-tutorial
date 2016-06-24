require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest
  test "invalid signup information" do
    get signup_path
    # ブロックの実行前と後で、`User.count`の値が変わらないことをテストする
    assert_no_difference 'User.count' do
      # users_pathにPOSTリクエスト→createアクション
      post users_path, user: { name:  "",
                               email: "user@invalid",
                               password:              "foo",
                               password_confirmation: "bar" }
    end
    # サインアップが失敗したとき、再度`users/new`がレンダリングされることをテスト
    assert_template 'users/new'
  end
end
