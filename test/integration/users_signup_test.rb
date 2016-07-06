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

  test "valid signup information" do
    get signup_path
    # ブロックの実行前と後で、`User.count`の値が+1違うこと
    assert_difference 'User.count', 1 do
      # `post_via_redirect`：postしたあとリダイレクトを追う
      post_via_redirect users_path, user: { name:  "Example User",
                                            email: "user@example.com",
                                            password:              "password",
                                            password_confirmation: "password" }
    end
  end
end
