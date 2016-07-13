require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test "micropost interface" do
    log_in_as(@user)
    get root_path
    assert_select 'div.pagination'

    # Invalid submission
    # 無効な投稿は受け付けず、エラーを表示すること
    assert_no_difference 'Micropost.count' do
      post microposts_path, micropost: { content: "" }
    end
    assert_select 'div#error_explanation'

    # Valid submission
    content = "This micropost really ties the room together"
    assert_difference 'Micropost.count', 1 do
      post microposts_path, micropost: { content: content }
    end
    # リダイレクトしたら先ほどの投稿が追加されていること
    assert_redirected_to root_url
    follow_redirect!
    assert_match content, response.body

    # Delete a post.
    assert_select 'a', text: 'delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end

    # Visit a different user.
    # 他のユーザーには削除リンクが表示されないこと
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end
end
