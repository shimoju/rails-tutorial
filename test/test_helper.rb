ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'
require "minitest/reporters"
Minitest::Reporters.use!

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...

  # Returns true if a test user is logged in.
  def is_logged_in?
    !session[:user_id].nil?
  end

  # Logs in a test user.
  def log_in_as(user, options = {})
    # ハッシュはキーが存在しなければnilが返るので、`|| 'デフォルト値'`と書ける
    password    = options[:password]    || 'password'
    remember_me = options[:remember_me] || '1'
    # インテグレーションテストの場合は（通常のように）postすることでログインし、
    # そうでない場合はsessionメソッドを直接使ってログインとする
    if integration_test?
      post login_path, session: { email:       user.email,
                                  password:    password,
                                  remember_me: remember_me }
    else
      session[:user_id] = user.id
    end
  end

  private

    # Returns true inside an integration test.
    # `post_via_redirect`メソッドが定義されていればインテグレーションテストとする
    def integration_test?
      defined?(post_via_redirect)
    end
end
