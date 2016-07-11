require 'test_helper'

class UserMailerTest < ActionMailer::TestCase
  test "account_activation" do
    user = users(:michael)
    user.activation_token = User.new_token
    # アクティベーションメールを作成
    mail = UserMailer.account_activation(user)
    assert_equal "Account activation", mail.subject
    # to, fromは配列
    assert_equal [user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
    assert_match user.name,               mail.body.encoded
    assert_match user.activation_token,   mail.body.encoded
    # 本文記載のアクティベーションURLにあるメールアドレス(Query stringの値)
    # を検索したいので、`CGI::escape`でエスケープする
    # ex) http://example.com/account_activations/nn-N5qR0nRj7hAS4N5_bGQ/edit?email=michael%40example.com
    assert_match CGI::escape(user.email), mail.body.encoded
  end

  test "password_reset" do
    user = users(:michael)
    user.reset_token = User.new_token
    mail = UserMailer.password_reset(user)
    assert_equal "Password reset", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
    assert_match user.reset_token,        mail.body.encoded
    # 上のアクティベーションメールと同様の理由でエスケープする
    # ex) http://example.com/password_resets/xOaoHL9BRnfAq3Fw-Gs8lw/edit?email=michael%40example.com
    assert_match CGI::escape(user.email), mail.body.encoded
  end
end
