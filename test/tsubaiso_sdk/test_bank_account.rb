require 'minitest/autorun'
require_relative './common_setup_and_teardown.rb'

class BankAccountTest < Minitest::Test
  include CommonSetupAndTeardown

  def setup
    super("bank_accounts")
  end

  def test_create_bank_account
    options = {
      bank_account_master_id: "1",
      start_timestamp: "2016-07-30",
      finish_timestamp: "2016-08-30",
    }
    new_bank_account = @api.create_bank_account(options)

    assert_equal 200, new_bank_account[:status].to_i, new_bank_account.inspect
    serch_options = {
      year: 2016,
      month: 8
    }
    listed_bank_accounts = @api.list_bank_account(serch_options)
    assert_equal 200, listed_bank_accounts[:status].to_i, listed_bank_accounts.inspect
    target_bank_account = listed_bank_accounts[:json].find{ |bank_account| bank_account[:id] == new_bank_account[:json][:id]}

    assert_equal Time.parse(options[:start_timestamp]), Time.parse(target_bank_account[:start_timestamp])
    assert_equal Time.parse(options[:finish_timestamp]), Time.parse(target_bank_account[:finish_timestamp])
    assert_equal options[:bank_account_master_id], target_bank_account[:bank_account_master_id]
  end

end

