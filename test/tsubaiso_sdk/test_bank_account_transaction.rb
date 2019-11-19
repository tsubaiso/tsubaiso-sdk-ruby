require 'minitest/autorun'
require 'time'
require_relative '../../lib/tsubaiso_sdk'
require_relative '../stubbings/stub_register.rb'

include WebMock::API

class BankAccountTransactionTest < Minitest::Test

  def setup
    WebMock.enable!
    WebMock.disable_net_connect!
    @api = TsubaisoSDK.new({ base_url: ENV['SDK_BASE_URL'], access_token: ENV['SDK_ACCESS_TOKEN'] })
    StubRegister.new(
      "bank_account_transactions",
      @api.instance_variable_get(:@base_url),
      @api.instance_variable_get(:@access_token)
    )

    @bank_account_transaction_1 = {
      bank_account_id: 0,
      journal_timestamp: "2019-07-25",
      price_value: 1000,
      reason_code: "xxxx_123",
      dc: "d",
      brief: "this is sample transactions",
      memo: "this is created from API.",
      dept_code: "HEAD"
    }
  end

  def test_create_bank_account_transaction
    created_bat = @api.create_bank_account_transaction(@bank_account_transaction_1)
    assert_equal 200, created_bat[:status].to_i, created_bat.inspect

    shown_bat = @api.show_bank_account_transaction(created_bat[:json][:id])
    assert_equal 200, shown_bat[:status].to_i, shown_bat.inspect
    assert_equal  created_bat[:json][:id], shown_bat[:json][:id]

    listed_bats = @api.list_bank_account_transactions(@bank_account_transaction_1[:bank_account_id])
    target_bat = listed_bats[:json].find{ |bat| bat[:id] == created_bat[:json][:id]}

    assert target_bat != nil
    assert_equal Time.parse(@bank_account_transaction_1[:journal_timestamp]), Time.parse(target_bat[:journal_timestamp])
    assert_equal @bank_account_transaction_1[:price_value], target_bat[:price_value]
    assert_equal @bank_account_transaction_1[:memo], target_bat[:memo]
  end

  def test_update_bank_account_transaction
    created_bank_account_transaction = @api.create_bank_account_transaction(@bank_account_transaction_1)
    assert_equal 200, created_bank_account_transaction[:status].to_i, created_bank_account_transaction.inspect

    update_options = {
      price_value: 500,
      reason_code: "TEST_CASH_HATAGAYA",
      brief: "this is sample updated transactions",
      dc: 'd'
    }

    update_options[:id] = created_bank_account_transaction[:json][:id]
    updated_bat = @api.update_bank_account_transaction(update_options)[:json]
    assert_equal 200, @api.update_bank_account_transaction(update_options)[:status].to_i

    assert_equal update_options[:price_value], updated_bat[:price_value]
    assert_equal update_options[:reason_code], updated_bat[:reason_code]
    assert_equal update_options[:brief], updated_bat[:brief]
    assert_equal update_options[:dc], updated_bat[:dc]

    assert_equal Time.parse(@bank_account_transaction_1[:journal_timestamp]), Time.parse(updated_bat[:journal_timestamp])
    assert_equal @bank_account_transaction_1[:memo], updated_bat[:memo]
  end

  def teardown
    WebMock.disable!
  end
end