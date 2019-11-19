require 'minitest/autorun'
require 'time'
require_relative '../../lib/tsubaiso_sdk'
require_relative '../stubbings/stub_register.rb'

include WebMock::API

class BankAccountMasterTest < Minitest::Test

  def setup
    WebMock.enable!
    WebMock.disable_net_connect!
    @api = TsubaisoSDK.new({ base_url: ENV['SDK_BASE_URL'], access_token: ENV['SDK_ACCESS_TOKEN'] })
    StubRegister.new(
      "bank_account_masters",
      @api.instance_variable_get(:@base_url),
      @api.instance_variable_get(:@access_token)
    )

    @bank_account_master_1 = {
      name: "ANZ Bank",
      account_type: "1",
      account_number: "66667777",
      nominee: "tsubaiso taro",
      memo: "",
      start_ymd: "2019-06-01",
      finish_ymd: nil,
      zengin_bank_code: "7777",
      zengin_branch_code: "777",
      zengin_client_code_sogo: "9999999999",
      currency_code: "",
      currency_rate_master_code: nil
    }

    @bank_account_master_2 = {
      name: "NSW Bank",
      account_type: "1",
      account_number: "66665555",
      nominee: "tsubaiso jiro",
      memo: "",
      start_ymd: "2019-06-02",
      finish_ymd: nil,
      zengin_bank_code: "8888",
      zengin_branch_code: "777",
      zengin_client_code_sogo: "8888888888",
      currency_code: "",
      currency_rate_master_code: nil
    }

    @bank_account_master_3 = {
      name: "Bank of Melbourne",
      account_type: "1",
      account_number: "66664444",
      nominee: "tsubaiso saburo",
      memo: "",
      start_ymd: "2019-06-03",
      finish_ymd: nil,
      zengin_bank_code: "9999",
      zengin_branch_code: "999",
      zengin_client_code_sogo: "7777777777",
      currency_code: "",
      currency_rate_master_code: nil
    }
  end

  def test_create_bank_account_master
    created_bank_account_master = @api.create_bank_account_master(@bank_account_master_1)

    assert_equal 200, created_bank_account_master[:status].to_i, created_bank_account_master.inspect
    assert_equal @bank_account_master_1[:name], created_bank_account_master[:json][:name]
    assert_equal @bank_account_master_1[:account_number], created_bank_account_master[:json][:account_number]
    assert_equal @bank_account_master_1[:zengin_bank_code], created_bank_account_master[:json][:zengin_bank_code]
    assert_equal @bank_account_master_1[:zengin_branch_code], created_bank_account_master[:json][:zengin_branch_code]
  end

  def test_show_bank_account_master
    created_bank_account_master = @api.create_bank_account_master(@bank_account_master_1)
    shown_bank_account_master = @api.show_bank_account_master(created_bank_account_master[:json][:id])

    assert_equal @bank_account_master_1[:nominee], shown_bank_account_master[:json][:nominee]
    assert_equal @bank_account_master_1[:name], shown_bank_account_master[:json][:name]
    assert_equal @bank_account_master_1[:account_number], shown_bank_account_master[:json][:account_number]
  end

  def test_list_bank_account_masters
    created_bank_account_master_1 = @api.create_bank_account_master(@bank_account_master_1)
    created_bank_account_master_2 = @api.create_bank_account_master(@bank_account_master_2)
    created_bank_account_master_3 = @api.create_bank_account_master(@bank_account_master_3)

    assert_equal 200, created_bank_account_master_1[:status].to_i
    assert_equal 200, created_bank_account_master_2[:status].to_i
    assert_equal 200, created_bank_account_master_3[:status].to_i

    created_master_id_1 = created_bank_account_master_1[:json][:id]
    created_master_id_2 = created_bank_account_master_2[:json][:id]
    created_master_id_3 = created_bank_account_master_3[:json][:id]

    bank_account_master_list = @api.list_bank_account_masters
    assert_equal 200, bank_account_master_list[:status].to_i, bank_account_master_list.inspect
    assert(bank_account_master_list[:json].any? { |x| x[:id] == created_master_id_1 })
    assert(bank_account_master_list[:json].any? { |x| x[:id] == created_master_id_2 })
    assert(bank_account_master_list[:json].any? { |x| x[:id] == created_master_id_3 })
  end

  def test_update_bank_account_master
    created_bank_account_master = @api.create_bank_account_master(@bank_account_master_1)
    assert_equal 200, created_bank_account_master[:status].to_i

    updating_options = {
      id: created_bank_account_master[:json][:id],
      name: "Westpac",
      account_type: "3",
      nominee: "Hatagaya Taro",
      memo: "This is updatting test"
    }

    updated_bank_account_master = @api.update_bank_account_master(updating_options)
    assert_equal 200, updated_bank_account_master[:status].to_i
    assert_equal updating_options[:name], updated_bank_account_master[:json][:name]
    assert_equal updating_options[:memo], updated_bank_account_master[:json][:memo]
    assert_equal updating_options[:nominee], updated_bank_account_master[:json][:nominee]
    assert_equal updating_options[:account_type], updated_bank_account_master[:json][:account_type]

    assert_equal @bank_account_master_1[:account_number], updated_bank_account_master[:json][:account_number]
    assert_equal @bank_account_master_1[:zengin_bank_code], updated_bank_account_master[:json][:zengin_bank_code]
    assert_equal @bank_account_master_1[:zengin_branch_code], updated_bank_account_master[:json][:zengin_branch_code]
  end

  def teardown
    WebMock.disable!
  end

end

