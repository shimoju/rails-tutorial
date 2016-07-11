require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  def setup
    @user = users(:michael)
    @other_user = users(:archer)
    @inactive_user = users(:inactive)
  end

  test "should redirect index when not logged in" do
    get :index
    assert_redirected_to login_url
  end

  # アクティベートされていないユーザーはindexに含まないこと
  test "should not include inactive user" do
    log_in_as(@user)
    get :index
    index_users = assigns(:users)
    assert index_users.include?(@user)
    assert_not index_users.include?(@inactive_user)
  end

  # ユーザーがアクティベートされていないときは、トップページにリダイレクトすること
  test "should redirect show when inactive user" do
    get :show, id: @user
    assert_response :success
    get :show, id: @inactive_user
    assert_redirected_to root_url
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  # ログインしていないときはログインページにリダイレクトすること
  test "should redirect edit when not logged in" do
    get :edit, id: @user
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  test "should redirect update when not logged in" do
    patch :update, id: @user, user: { name: @user.name, email: @user.email }
    assert_not flash.empty?
    assert_redirected_to login_url
  end

  # ログインしている本人以外はプロフィールを編集できないこと
  test "should redirect edit when logged in as wrong user" do
    log_in_as(@other_user)
    get :edit, id: @user
    assert flash.empty?
    assert_redirected_to root_url
  end

  test "should redirect update when logged in as wrong user" do
    log_in_as(@other_user)
    patch :update, id: @user, user: { name: @user.name, email: @user.email }
    assert flash.empty?
    assert_redirected_to root_url
  end

  # ログインしていない場合はユーザーを削除せずリダイレクトすること
  test "should redirect destroy when not logged in" do
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    assert_redirected_to login_url
  end

  # ログインしているがadminではないときも、ユーザーを削除せずリダイレクトすること
  test "should redirect destroy when logged in as a non-admin" do
    log_in_as(@other_user)
    assert_no_difference 'User.count' do
      delete :destroy, id: @user
    end
    assert_redirected_to root_url
  end
end
