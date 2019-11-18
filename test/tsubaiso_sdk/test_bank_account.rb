require 'minitest/autorun'
require 'time'
require_relative '../../lib/tsubaiso_sdk'
require_relative '../stubbings/stub_register.rb'

include WebMock::API
WebMock.disable_net_connect!

class TsubaisoSDKTest < Minitest::Test
  def setup
    @api = TsubaisoSDK.new({ base_url: ENV['SDK_BASE_URL'], access_token: ENV['SDK_ACCESS_TOKEN'] })
    Stubbing.new("bank_accounts")
  end

  def test_create_bank_account
    options = {
      bank_account_master_id: "1",
      start_timestamp: "2019-06-30",
      finish_timestamp: "2019-07-30",
    }
    new_bank_account = @api.create_bank_account(options)

    assert_equal 200, new_bank_account[:status].to_i, new_bank_account.inspect
    serch_options = {
      year: 2019,
      month: 7
    }
    listed_bank_accounts = @api.list_bank_account(serch_options)
    assert_equal 200, listed_bank_accounts[:status].to_i, listed_bank_accounts.inspect
    target_bank_account = listed_bank_accounts[:json].find{ |bank_account| bank_account[:id] == new_bank_account[:json][:id]}

    assert_equal Time.parse(options[:start_timestamp]), Time.parse(target_bank_account[:start_timestamp])
    assert_equal Time.parse(options[:finish_timestamp]), Time.parse(target_bank_account[:finish_timestamp])
    assert_equal options[:bank_account_master_id], target_bank_account[:bank_account_master_id]
  end
end

