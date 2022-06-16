require 'test_helper'

class TaskMailerTest < ActionMailer::TestCase
  test "email_reminder" do
    mail = TaskMailer.email_reminder
    assert_equal "Email reminder", mail.subject
    assert_equal ["to@example.org"], mail.to
    assert_equal ["from@example.com"], mail.from
    assert_match "Hi", mail.body.encoded
  end

end
