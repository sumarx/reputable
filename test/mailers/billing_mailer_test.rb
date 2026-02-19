require "test_helper"

class BillingMailerTest < ActionMailer::TestCase
  test "invoice_generated" do
    mail = BillingMailer.invoice_generated
    assert_equal "Invoice generated", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "payment_reminder" do
    mail = BillingMailer.payment_reminder
    assert_equal "Payment reminder", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "account_suspended" do
    mail = BillingMailer.account_suspended
    assert_equal "Account suspended", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "payment_confirmed" do
    mail = BillingMailer.payment_confirmed
    assert_equal "Payment confirmed", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end

  test "payment_proof_submitted" do
    mail = BillingMailer.payment_proof_submitted
    assert_equal "Payment proof submitted", mail.subject
    assert_equal [ "to@example.org" ], mail.to
    assert_equal [ "from@example.com" ], mail.from
    assert_match "Hi", mail.body.encoded
  end
end
